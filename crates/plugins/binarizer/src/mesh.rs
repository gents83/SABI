use std::mem::size_of;

use inox_math::{VecBase, VecBaseFloat, Vector2, Vector3, Vector4};
use inox_render::{MeshData, MeshletData, VertexAttributeLayout};
use inox_resources::to_slice;
use meshopt::DecodePosition;

#[derive(Debug, Clone, Copy)]
pub struct MeshVertex {
    pub pos: Vector4,
    pub color: Vector4,
    pub normal: Vector4,
    pub tangent: Vector4,
    pub uv_0: Vector2,
    pub uv_1: Vector2,
    pub uv_2: Vector2,
    pub uv_3: Vector2,
}

impl Default for MeshVertex {
    fn default() -> Self {
        Self {
            pos: Vector4::default_zero(),
            color: Vector4::default_zero(),
            normal: Vector4::default_zero(),
            tangent: Vector4::default_zero(),
            uv_0: Vector2::default_zero(),
            uv_1: Vector2::default_zero(),
            uv_2: Vector2::default_zero(),
            uv_3: Vector2::default_zero(),
        }
    }
}

impl meshopt::DecodePosition for MeshVertex {
    fn decode_position(&self) -> [f32; 3] {
        self.pos.xyz().into()
    }
}

pub fn optimize_mesh<T>(vertices: &[T], indices: &[u32]) -> (Vec<T>, Vec<u32>)
where
    T: Clone + Default,
{
    let vertices_bytes = to_slice(vertices);
    let vertex_stride = size_of::<T>();
    debug_assert!(
        vertex_stride % size_of::<f32>() == 0,
        "Vertex size is not a multiple of f32 - meshopt will fail"
    );
    let vertex_data_adapter = meshopt::VertexDataAdapter::new(vertices_bytes, vertex_stride, 0);

    let mut new_indices = meshopt::optimize_vertex_cache(indices, vertices.len());
    let threshold = 1.01; // allow up to 1% worse ACMR to get more reordering opportunities for overdraw
    meshopt::optimize_overdraw_in_place(
        new_indices.as_mut_slice(),
        vertex_data_adapter.as_ref().unwrap(),
        threshold,
    );
    let new_vertices = meshopt::optimize_vertex_fetch(&mut new_indices, vertices);

    (new_vertices, new_indices)
}

pub fn create_mesh_data(
    vertex_layout: VertexAttributeLayout,
    vertices: &[MeshVertex],
    indices: &[u32],
) -> MeshData {
    let mut mesh_data = MeshData {
        vertex_layout: VertexAttributeLayout::HasPosition,
        aabb_max: Vector3::new(-f32::INFINITY, -f32::INFINITY, -f32::INFINITY),
        aabb_min: Vector3::new(f32::INFINITY, f32::INFINITY, f32::INFINITY),
        ..Default::default()
    };
    vertices.iter().for_each(|v| {
        mesh_data.aabb_max = mesh_data.aabb_max.max(v.pos.xyz());
        mesh_data.aabb_min = mesh_data.aabb_min.min(v.pos.xyz());
    });
    mesh_data.vertex_layout = vertex_layout;
    mesh_data.indices = indices.to_vec();
    mesh_data.vertex_positions.reserve(vertices.len());
    mesh_data
        .vertex_attributes
        .reserve(VertexAttributeLayout::all().stride_in_count() * vertices.len());
    vertices.iter().for_each(|v| {
        mesh_data.insert_position(v.pos.xyz());
        if vertex_layout.intersects(VertexAttributeLayout::HasColor) {
            mesh_data.insert_color(v.color);
        }
        if vertex_layout.intersects(VertexAttributeLayout::HasNormal) {
            mesh_data.insert_normal(v.normal.xyz());
        }
        if vertex_layout.intersects(VertexAttributeLayout::HasTangent) {
            mesh_data.insert_tangent(v.tangent);
        }
        if vertex_layout.intersects(VertexAttributeLayout::HasUV1) {
            mesh_data.insert_uv(v.uv_0);
        }
        if vertex_layout.intersects(VertexAttributeLayout::HasUV2) {
            mesh_data.insert_uv(v.uv_1);
        }
        if vertex_layout.intersects(VertexAttributeLayout::HasUV3) {
            mesh_data.insert_uv(v.uv_2);
        }
        if vertex_layout.intersects(VertexAttributeLayout::HasUV4) {
            mesh_data.insert_uv(v.uv_3);
        }
    });
    mesh_data
}

pub fn compute_meshlets<T>(
    vertices: &[T],
    indices: &[u32],
    starting_offset: u32,
) -> (Vec<MeshletData>, Vec<u32>)
where
    T: DecodePosition,
{
    let vertices_bytes = to_slice(vertices);
    let vertex_stride = size_of::<T>();
    debug_assert!(
        vertex_stride % size_of::<f32>() == 0,
        "Vertex size is not a multiple of f32 - meshopt will fail"
    );
    let vertex_data_adapter = meshopt::VertexDataAdapter::new(vertices_bytes, vertex_stride, 0);

    let mut new_meshlets = Vec::new();
    let max_vertices = 128;
    let max_triangles = 256;
    let cone_weight = 0.5;
    let meshlets = meshopt::build_meshlets(
        indices,
        vertex_data_adapter.as_ref().unwrap(),
        max_vertices,
        max_triangles,
        cone_weight,
    );
    debug_assert!(!meshlets.meshlets.is_empty());

    let mut new_indices = Vec::new();
    for m in meshlets.iter() {
        let index_offset = new_indices.len();
        debug_assert!(m.triangles.len() % 3 == 0);
        let mut aabb_max = Vector3::new(f32::NEG_INFINITY, f32::NEG_INFINITY, f32::NEG_INFINITY);
        let mut aabb_min = Vector3::new(f32::INFINITY, f32::INFINITY, f32::INFINITY);
        m.triangles.iter().for_each(|&i| {
            let index = m.vertices[i as usize] as usize;
            new_indices.push(index as u32);
            let pos = vertices[index].decode_position().into();
            aabb_min = aabb_min.min(pos);
            aabb_max = aabb_max.max(pos);
        });
        debug_assert!(new_indices.len() % 3 == 0);
        new_meshlets.push(MeshletData {
            indices_offset: starting_offset + index_offset as u32,
            indices_count: m.triangles.len() as _,
            aabb_min,
            aabb_max,
            cluster_error: 0.0,
            parent_error: f32::INFINITY,
            ..Default::default()
        });
    }
    (new_meshlets, new_indices)
}

pub fn compute_clusters(
    groups: &[Vec<u32>],
    parent_meshlets: &mut [MeshletData],
    parent_meshlets_offset: usize,
    mesh_indices_offset: usize,
    vertices: &[MeshVertex],
    indices: &[u32],
    lod_level: i32,
) -> (Vec<u32>, Vec<MeshletData>) {
    //println!("Start cluster");
    let mut indices_offset = mesh_indices_offset;
    let mut cluster_indices = Vec::new();
    let mut cluster_meshlets = Vec::new();
    groups.iter().for_each(|meshlets_indices| {
        let mut group_indices = Vec::new();
        let mut group_vertices = Vec::new();
        let mut aabb_max = Vector3::new(f32::NEG_INFINITY, f32::NEG_INFINITY, f32::NEG_INFINITY);
        let mut aabb_min = Vector3::new(f32::INFINITY, f32::INFINITY, f32::INFINITY);
        let mut children_error = 0.0f32;

        //println!("Group: {:?}", _group_i);
        //print!("\tChildren meshlets: ");
        meshlets_indices.iter().for_each(|&meshlet_index| {
            //print!("{} ", parent_meshlets_offset + meshlet_index as usize);
            let meshlet = &parent_meshlets[meshlet_index as usize];
            let count = meshlet.indices_count;
            for i in 0..count {
                let global_index = indices[meshlet.indices_offset as usize + i as usize] as usize;
                let group_index = if let Some(index) = group_vertices
                    .iter()
                    .position(|v: &MeshVertex| v.pos.w as usize == global_index)
                {
                    index
                } else {
                    let mut v = vertices[global_index];
                    v.pos.w = global_index as f32;
                    group_vertices.push(v);
                    group_vertices.len() - 1
                };
                group_indices.push(group_index as u32);
            }
            aabb_max = aabb_max.max(meshlet.aabb_max);
            aabb_min = aabb_min.min(meshlet.aabb_min);
            children_error = children_error.max(meshlet.cluster_error);
        });
        //println!();

        let vertices_bytes = to_slice(&group_vertices);
        let vertex_stride = size_of::<MeshVertex>();
        debug_assert!(
            vertex_stride % size_of::<f32>() == 0,
            "Vertex size is not a multiple of f32 - meshopt will fail"
        );
        let vertex_data_adapter = meshopt::VertexDataAdapter::new(vertices_bytes, vertex_stride, 0);

        let local_scale = meshopt::simplify_scale(vertex_data_adapter.as_ref().unwrap());

        let target_count = (group_indices.len() as f32 * 0.5) as usize;
        let target_error = 0.1 * lod_level as f32 + 0.01 * (1 - lod_level) as f32;
        let mut simplification_error = 0.0;

        let mut simplified_indices = meshopt::simplify(
            &group_indices,
            vertex_data_adapter.as_ref().unwrap(),
            target_count,
            target_error,
            meshopt::SimplifyOptions::LockBorder
                | meshopt::SimplifyOptions::Sparse
                | meshopt::SimplifyOptions::ErrorAbsolute,
            Some(&mut simplification_error),
        );

        let mesh_error = simplification_error * local_scale + children_error;
        let half_length = (aabb_max - aabb_min) * 0.5;
        let center = aabb_min + half_length;
        let radius = half_length.length();

        if simplified_indices.len() >= group_indices.len() {
            inox_log::debug_log!(
                "No simplification happened [from {} to {}]",
                group_indices.len(),
                simplified_indices.len(),
            );
        }

        if simplified_indices.is_empty() {
            simplified_indices = group_indices;
        }

        //println!("\tCluster error: {}", mesh_error);
        //println!(
        //    "\tBounding Sphere: {:?}",
        //    Vector4::new(center.x, center.y, center.z, radius)
        //);
        //println!("\tComputing new inner meshlets for group: {:?}", group_i);

        let (mut meshlets, group_indices) =
            compute_meshlets(&group_vertices, &simplified_indices, indices_offset as u32);

        let mut global_group_indices = Vec::with_capacity(group_indices.len());
        group_indices.iter().for_each(|&i| {
            global_group_indices.push(group_vertices[i as usize].pos.w as u32);
        });
        let lod_level_meshlet_starting_index = parent_meshlets_offset + parent_meshlets.len();
        let _cluster_starting_index = lod_level_meshlet_starting_index + cluster_meshlets.len();
        //print!("\tParent meshlets: ");
        meshlets.iter_mut().for_each(|m| {
            //print!("{} ", _cluster_starting_index + _i);
            m.cluster_error = mesh_error;
            m.bounding_sphere = Vector4::new(center.x, center.y, center.z, radius);
            meshlets_indices.iter().for_each(|&meshlet_index| {
                m.child_meshlets
                    .push(parent_meshlets_offset as u32 + meshlet_index);
                parent_meshlets[meshlet_index as usize].parent_error = m.cluster_error;
                parent_meshlets[meshlet_index as usize].parent_bounding_sphere = m.bounding_sphere;
            });
        });
        //println!();
        indices_offset += global_group_indices.len();

        cluster_indices.append(&mut global_group_indices);
        cluster_meshlets.append(&mut meshlets);
    });

    //println!("End cluster");
    (cluster_indices, cluster_meshlets)
}

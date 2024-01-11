use std::{
    collections::HashMap,
    sync::{
        atomic::{AtomicU32, Ordering},
        Arc, RwLock,
    },
};

use inox_bvh::{create_linearized_bvh, BVHTree, GPUBVHNode, AABB};
use inox_math::{quantize_snorm, InnerSpace, Mat4Ops, Matrix4, VecBase};
use inox_resources::{to_slice, Buffer, HashBuffer, Resource, ResourceId};
use inox_uid::{generate_random_uid, generate_static_uid_from_string};

use crate::{
    AsBinding, DispatchCommandSize, GPUMaterial, GPUMesh, GPUMeshlet, GPURuntimeVertexData, Light,
    LightData, LightId, Material, MaterialData, MaterialFlags, MaterialId, Mesh, MeshData,
    MeshFlags, MeshId, RenderCommandsPerType, Texture, TextureId, TextureInfo, TextureType, VecU32,
};

pub const TLAS_UID: ResourceId = generate_static_uid_from_string("TLAS");
pub const LUT_PBR_CHARLIE_UID: ResourceId = generate_static_uid_from_string("LUT_PBR_CHARLIE_UID");
pub const LUT_PBR_GGX_UID: ResourceId = generate_static_uid_from_string("LUT_PBR_GGX_UID");

pub const ATOMIC_SIZE: u32 = 32;
pub const PREALLOCATED_MIN_SIZE: usize = 1;

pub type TexturesBuffer = Arc<RwLock<HashBuffer<TextureId, TextureInfo, PREALLOCATED_MIN_SIZE>>>;
pub type MaterialsBuffer = Arc<RwLock<HashBuffer<MaterialId, GPUMaterial, PREALLOCATED_MIN_SIZE>>>;
pub type LightsBuffer = Arc<RwLock<HashBuffer<LightId, LightData, PREALLOCATED_MIN_SIZE>>>;
pub type DrawCommandsBuffer = Arc<RwLock<HashMap<MeshFlags, RenderCommandsPerType>>>;
pub type DispatchCommandBuffer = Arc<RwLock<HashMap<ResourceId, DispatchCommandSize>>>;
pub type TexturesLUT = Arc<RwLock<HashMap<ResourceId, Resource<Texture>>>>;
pub type MeshesBuffer = Arc<RwLock<HashBuffer<MeshId, GPUMesh, 0>>>;
pub type MeshletsBuffer = Arc<RwLock<Buffer<GPUMeshlet, 0>>>; //MeshId <-> [GPUMeshlet]
pub type BVHBuffer = Arc<RwLock<Buffer<GPUBVHNode, 0>>>;
pub type IndicesBuffer = Arc<RwLock<Buffer<u32, 0>>>; //MeshId <-> [u32]
pub type VertexPositionsBuffer = Arc<RwLock<Buffer<u32, 0>>>; //MeshId <-> [u32] (10 x, 10 y, 10 z, 2 null)
pub type VertexAttributesBuffer = Arc<RwLock<Buffer<u32, 0>>>; //MeshId <-> [u32]
pub type RuntimeVerticesBuffer = Arc<RwLock<Buffer<GPURuntimeVertexData, 0>>>;
pub type AtomicCounter = Arc<RwLock<AtomicU32>>;
pub type AtomicCounters = Arc<RwLock<VecU32>>;

//Alignment should be 4, 8, 16 or 32 bytes
#[derive(Default)]
pub struct GlobalBuffers {
    pub textures: TexturesBuffer,
    pub lut_textures: TexturesLUT,
    pub lights: LightsBuffer,
    pub materials: MaterialsBuffer,
    pub draw_commands: DrawCommandsBuffer,
    pub dispatch_commands: DispatchCommandBuffer,
    pub meshes: MeshesBuffer,
    pub meshlets: MeshletsBuffer,
    pub bvh: BVHBuffer,
    pub triangles_ids: RwLock<HashMap<MeshId, Vec<ResourceId>>>,
    pub indices: IndicesBuffer,
    pub vertex_positions: VertexPositionsBuffer,
    pub vertex_attributes: VertexAttributesBuffer,
    pub runtime_vertices: RuntimeVerticesBuffer,
    pub culling_result: AtomicCounters,
    pub tlas_start_index: AtomicCounter,
    pub radiance_data_buffer: AtomicCounters,
    pub atomic_counters: AtomicCounters,
}

impl GlobalBuffers {
    fn extract_meshlets(
        &self,
        mesh_data: &MeshData,
        mesh_id: &MeshId,
        mesh_index: u32,
        indices_offset: u32,
    ) -> (usize, usize) {
        inox_profiler::scoped_profile!("render_buffers::extract_meshlets");

        let mut meshlets = Vec::new();
        meshlets.resize(mesh_data.meshlets.len(), GPUMeshlet::default());
        mesh_data
            .meshlets
            .iter()
            .enumerate()
            .for_each(|(i, meshlet_data)| {
                let triangle_id = generate_random_uid();
                self.triangles_ids
                    .write()
                    .unwrap()
                    .entry(*mesh_id)
                    .or_default()
                    .push(triangle_id);
                let triangle_bhv_range = self
                    .bvh
                    .write()
                    .unwrap()
                    .allocate(&triangle_id, &meshlet_data.triangles_bvh)
                    .1;
                let triangles_bhv_index = triangle_bhv_range.start as _;
                self.bvh.write().unwrap().data_mut()[triangle_bhv_range]
                    .iter_mut()
                    .for_each(|n| {
                        if n.miss >= 0 {
                            n.miss += triangles_bhv_index as i32;
                        }
                    });
                let cone_axis = meshlet_data.cone_axis.normalize();
                let cone_axis_cutoff = [
                    quantize_snorm(cone_axis.x, 8) as i8,
                    quantize_snorm(cone_axis.y, 8) as i8,
                    quantize_snorm(cone_axis.z, 8) as i8,
                    quantize_snorm(meshlet_data.cone_angle, 8) as i8,
                ];
                let meshlet = GPUMeshlet {
                    mesh_index,
                    indices_offset: (indices_offset + meshlet_data.indices_offset) as _,
                    indices_count: meshlet_data.indices_count,
                    triangles_bhv_index,
                    center: meshlet_data.cone_center.into(),
                    cone_axis_cutoff,
                };
                meshlets[i] = meshlet;
            });
        if meshlets.is_empty() {
            inox_log::debug_log!("No meshlet data for mesh {:?}", mesh_id);
        }
        let mesh_bhv_range = self
            .bvh
            .write()
            .unwrap()
            .allocate(mesh_id, &mesh_data.meshlets_bvh)
            .1;
        let blas_index = mesh_bhv_range.start as _;
        self.bvh.write().unwrap().data_mut()[mesh_bhv_range]
            .iter_mut()
            .for_each(|n| {
                if n.miss >= 0 {
                    n.miss += blas_index as i32;
                }
            });
        let meshlet_range = self
            .meshlets
            .write()
            .unwrap()
            .allocate(mesh_id, meshlets.as_slice())
            .1;
        (blas_index, meshlet_range.start)
    }
    fn add_vertex_data(
        &self,
        mesh_id: &MeshId,
        mesh_index: u32,
        mesh_data: &MeshData,
    ) -> (u32, u32, u32) {
        inox_profiler::scoped_profile!("render_buffers::add_vertex_data");

        debug_assert!(
            mesh_data.vertex_count() > 0,
            "No vertices for mesh {:?}",
            mesh_id
        );
        debug_assert!(
            !mesh_data.indices.is_empty(),
            "No indices for mesh {:?}",
            mesh_id
        );

        let vertex_offset = self
            .vertex_positions
            .write()
            .unwrap()
            .allocate(mesh_id, to_slice(mesh_data.vertex_positions.as_slice()))
            .1
            .start;
        let attributes_offset = self
            .vertex_attributes
            .write()
            .unwrap()
            .allocate(mesh_id, to_slice(mesh_data.vertex_attributes.as_slice()))
            .1
            .start;
        let runtime_vertices = vec![
            GPURuntimeVertexData {
                mesh_index,
                ..Default::default()
            };
            mesh_data.vertex_count()
        ];
        self.runtime_vertices
            .write()
            .unwrap()
            .allocate(mesh_id, runtime_vertices.as_slice());
        let indices_offset = self
            .indices
            .write()
            .unwrap()
            .allocate(mesh_id, mesh_data.indices.as_slice())
            .1
            .start;
        (
            vertex_offset as _,
            indices_offset as _,
            attributes_offset as _,
        )
    }
    pub fn add_mesh(&self, mesh_id: &MeshId, mesh_data: &MeshData) {
        inox_profiler::scoped_profile!("render_buffers::add_mesh");
        self.remove_mesh(mesh_id, false);
        if mesh_data.vertex_count() == 0 {
            return;
        }
        let mesh_index = self
            .meshes
            .write()
            .unwrap()
            .insert(mesh_id, GPUMesh::default());

        let (vertex_offset, indices_offset, attributes_offset) =
            self.add_vertex_data(mesh_id, mesh_index as _, mesh_data);
        let (blas_index, meshlet_offset) =
            self.extract_meshlets(mesh_data, mesh_id, mesh_index as _, indices_offset);

        {
            let mut meshes = self.meshes.write().unwrap();
            let mesh = meshes.get_mut(mesh_id).unwrap();
            mesh.vertices_position_offset = vertex_offset;
            mesh.vertices_attribute_offset = attributes_offset;
            mesh.flags_and_vertices_attribute_layout = mesh_data.vertex_layout.into();
            mesh.blas_index = blas_index as _;
            mesh.meshlets_offset = meshlet_offset as _;
        }
        self.recreate_tlas();
        self.update_culling_data();
    }
    fn update_culling_data(&self) {
        let num_meshlets = self.meshlets.read().unwrap().item_count();
        let count = ((num_meshlets as u32 + ATOMIC_SIZE - 1) / ATOMIC_SIZE) as usize;
        self.culling_result
            .write()
            .unwrap()
            .set(vec![u32::MAX; count]);
    }
    fn recreate_tlas(&self) {
        inox_profiler::scoped_profile!("render_buffers::recreate_tlas");
        let mut meshes_aabbs = Vec::new();
        {
            let meshes = self.meshes.read().unwrap();
            let bhv = self.bvh.read().unwrap();
            let bhv = bhv.data();
            meshes.for_each_entry(|i, mesh| {
                let node = &bhv[mesh.blas_index as usize];
                let matrix = Matrix4::from_translation_orientation_scale(
                    mesh.position.into(),
                    mesh.orientation.into(),
                    mesh.scale.into(),
                );
                let min = matrix.rotate_point(node.min.into());
                let max = matrix.rotate_point(node.max.into());
                let aabb = AABB::create(min.min(max), max.max(min), i as _);
                meshes_aabbs.push(aabb);
            });
        }
        let bvh = BVHTree::new(&meshes_aabbs);
        let linearized_bhv = create_linearized_bvh(&bvh);
        let mut bvh = self.bvh.write().unwrap();
        let tlas_range = bvh.allocate(&TLAS_UID, &linearized_bhv).1;
        let tlas_starting_index = tlas_range.start as _;
        self.tlas_start_index
            .write()
            .unwrap()
            .store(tlas_starting_index, Ordering::SeqCst);
        bvh.data_mut()[tlas_range].iter_mut().for_each(|n| {
            if n.miss >= 0 {
                n.miss += tlas_starting_index as i32;
            }
        });
        //println!("\n\nTLAS: {}", tlas_starting_index);
        //print_bvh(bvh.data());
    }
    fn update_transform(&self, mesh: &mut Mesh, m: &mut GPUMesh) -> bool {
        inox_profiler::scoped_profile!("render_buffers::update_transform");

        let matrix = mesh.matrix();
        let new_pos = matrix.translation();
        let new_orientation = matrix.orientation();
        let new_scale = matrix.scale();
        let old_pos = m.position.into();
        let old_orientation = m.orientation.into();
        let old_scale = m.scale.into();
        if new_pos != old_pos || new_orientation != old_orientation || new_scale != old_scale {
            m.position = new_pos.into();
            m.orientation = new_orientation.into();
            m.scale = new_scale.into();
            return true;
        }
        false
    }
    pub fn change_mesh(&self, mesh_id: &MeshId, mesh: &mut Mesh) {
        inox_profiler::scoped_profile!("render_buffers::change_mesh");
        let mut is_matrix_changed = false;
        {
            let mut meshes = self.meshes.write().unwrap();
            if let Some(m) = meshes.get_mut(mesh_id) {
                if let Some(material) = mesh.material() {
                    if let Some(index) = self.materials.read().unwrap().index_of(material.id()) {
                        m.material_index = index as _;
                    }
                    if let Some(material) = self.materials.write().unwrap().get_mut(material.id()) {
                        let flags: MaterialFlags = material.flags.into();
                        if flags.contains(MaterialFlags::AlphaModeBlend)
                            || material.base_color[3] < 1.
                        {
                            mesh.remove_flag(MeshFlags::Opaque);
                            mesh.add_flag(MeshFlags::Tranparent);
                        }
                    }
                }

                is_matrix_changed = self.update_transform(mesh, m);

                let mesh_flags = mesh.flags();
                let vertex_attribute_layout = m.flags_and_vertices_attribute_layout & 0x0000FFFF;
                let flags: u32 = (*mesh_flags).into();
                m.flags_and_vertices_attribute_layout = vertex_attribute_layout | (flags << 16);
                {
                    let mut commands = self.draw_commands.write().unwrap();
                    commands.iter_mut().for_each(|(_, v)| {
                        v.remove_draw_commands(mesh_id);
                    });
                    let entry = commands.entry(*mesh_flags).or_default();
                    entry.add_mesh_commands(mesh_id, m, &self.meshlets.read().unwrap());
                }

                meshes.set_dirty(true);
            }
        }
        if is_matrix_changed {
            self.recreate_tlas();
        }
    }
    pub fn remove_mesh(&self, mesh_id: &MeshId, recreate_tlas: bool) {
        inox_profiler::scoped_profile!("render_buffers::remove_mesh");

        if self.meshes.write().unwrap().remove(mesh_id).is_some() {
            self.draw_commands
                .write()
                .unwrap()
                .iter_mut()
                .for_each(|(_, entry)| {
                    entry.remove_draw_commands(mesh_id);
                });
            self.meshlets.write().unwrap().remove(mesh_id);
            {
                let mut bhv = self.bvh.write().unwrap();
                bhv.remove(mesh_id);
                let mut triangle_ids = self.triangles_ids.write().unwrap();
                triangle_ids.get(mesh_id).unwrap().iter().for_each(|id| {
                    bhv.remove(id);
                });
                triangle_ids.remove(mesh_id);
            }
            self.indices.write().unwrap().remove(mesh_id);
            self.vertex_positions.write().unwrap().remove(mesh_id);
            self.runtime_vertices.write().unwrap().remove(mesh_id);
            self.vertex_attributes.write().unwrap().remove(mesh_id);
        }
        if recreate_tlas {
            self.recreate_tlas();
        }
        self.update_culling_data();
    }
    pub fn add_material(&self, material_id: &MaterialId, material: &mut Material) {
        inox_profiler::scoped_profile!("render_buffers::add_material");

        let mut textures_index_and_coord_set = [0; TextureType::Count as _];
        material
            .textures()
            .iter()
            .enumerate()
            .for_each(|(i, handle_texture)| {
                if let Some(texture) = handle_texture {
                    textures_index_and_coord_set[i] = (texture.get().texture_index() + 1) as u32;
                }
            });
        let mut materials = self.materials.write().unwrap();
        if let Some(m) = materials.get_mut(material_id) {
            m.textures_index_and_coord_set = textures_index_and_coord_set;
        } else {
            let index = materials.insert(
                material_id,
                GPUMaterial {
                    textures_index_and_coord_set,
                    ..Default::default()
                },
            );
            material.set_material_index(index as _);
        }
        materials.set_dirty(true);
    }
    pub fn update_material(&self, material_id: &MaterialId, material_data: &MaterialData) {
        inox_profiler::scoped_profile!("render_buffers::update_material");
        let mut materials = self.materials.write().unwrap();
        if let Some(material) = materials.get_mut(material_id) {
            for (i, t) in material_data.texcoords_set.iter().enumerate() {
                material.textures_index_and_coord_set[i] |= (*t << 28) as u32;
            }
            material.roughness_factor = material_data.roughness_factor;
            material.metallic_factor = material_data.metallic_factor;
            material.ior = material_data.ior;
            material.transmission_factor = material_data.transmission_factor;
            material.base_color = material_data.base_color.into();
            material.emissive_color = material_data.emissive_color.into();
            material.occlusion_strength = material_data.occlusion_strength;
            material.diffuse_color = material_data.diffuse_factor.into();
            material.specular_color = material_data.specular_glossiness_factor.into();
            material.attenuation_color_and_distance =
                material_data.attenuation_color_and_distance.into();
            material.thickness_factor = material_data.thickness_factor;
            material.alpha_cutoff = material_data.alpha_cutoff;
            material.emissive_strength = material_data.emissive_strength;
            material.flags = material_data.flags.into();
            materials.set_dirty(true);
        }
    }
    pub fn remove_material(&self, material_id: &MaterialId) {
        inox_profiler::scoped_profile!("render_buffers::remove_material");

        self.materials.write().unwrap().remove(material_id);
    }

    pub fn add_light(&self, light_id: &LightId, light: &mut Light) {
        inox_profiler::scoped_profile!("render_buffers::add_light");

        let index = self
            .lights
            .write()
            .unwrap()
            .insert(light_id, LightData::default());
        light.set_light_index(index as _);
    }
    pub fn update_light(&self, light_id: &LightId, light_data: &LightData) {
        inox_profiler::scoped_profile!("render_buffers::update_light");
        let mut lights = self.lights.write().unwrap();
        if let Some(light) = lights.get_mut(light_id) {
            *light = *light_data;
            lights.set_dirty(true);
        }
    }
    pub fn remove_light(&self, light_id: &LightId) {
        inox_profiler::scoped_profile!("render_buffers::remove_light");

        self.lights.write().unwrap().remove(light_id);
    }

    pub fn add_texture(&self, texture_id: &TextureId, texture_data: &TextureInfo) -> usize {
        inox_profiler::scoped_profile!("render_buffers::add_texture");

        self.textures
            .write()
            .unwrap()
            .insert(texture_id, *texture_data)
    }
    pub fn remove_texture(&self, texture_id: &TextureId) {
        inox_profiler::scoped_profile!("render_buffers::remove_texture");

        self.textures.write().unwrap().remove(texture_id);
    }
    #[allow(non_snake_case)]
    pub fn add_LUT_texture(&self, lut_id: ResourceId, texture: Resource<Texture>) {
        self.lut_textures.write().unwrap().insert(lut_id, texture);
    }
    #[allow(non_snake_case)]
    pub fn get_LUT_texture_id(&self, lut_id: &ResourceId) -> TextureId {
        *self.lut_textures.read().unwrap().get(lut_id).unwrap().id()
    }
}

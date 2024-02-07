#import "common.inc"
#import "utils.inc"

struct CullingData {
    view: mat4x4<f32>,
    mesh_flags: u32,
    lod0_meshlets_count: u32,
    _padding1: u32,
    _padding2: u32,
};

@group(0) @binding(0)
var<uniform> constant_data: ConstantData;
@group(0) @binding(1)
var<uniform> culling_data: CullingData;
@group(0) @binding(2)
var<storage, read> meshlets: Meshlets;
@group(0) @binding(3)
var<storage, read> meshes: Meshes;
@group(0) @binding(4)
var<storage, read> bhv: BHV;

@group(1) @binding(0)
var<storage, read_write> commands_count: atomic<u32>;
@group(1) @binding(1)
var<storage, read_write> commands: DrawIndexedCommands;
@group(1) @binding(2)
var<storage, read_write> meshlet_culling_data: array<atomic<u32>>;
@group(1) @binding(3)
var<storage, read_write> processing_data: array<atomic<u32>>;

#import "matrix_utils.inc"
#import "geom_utils.inc"

//ScreenSpace Frustum Culling
fn is_box_inside_frustum(min: vec3<f32>, max: vec3<f32>, frustum: array<vec4<f32>, 4>) -> bool {
    var visible: bool = false;    
    var points: array<vec3<f32>, 8>;
    points[0] = min;
    points[1] = max;
    points[2] = vec3<f32>(min.x, min.y, max.z);
    points[3] = vec3<f32>(min.x, max.y, max.z);
    points[4] = vec3<f32>(min.x, max.y, min.z);
    points[5] = vec3<f32>(max.x, min.y, min.z);
    points[6] = vec3<f32>(max.x, max.y, min.z);
    points[7] = vec3<f32>(max.x, min.y, max.z);
      
    var f = frustum;
    for(var i = 0; !visible && i < 4; i = i + 1) {  
        for(var p = 0; !visible && p < 8; p = p + 1) {        
            visible = visible || !(dot(f[i].xyz, points[p]) + f[i].w <= 0.);
        }
    }   
    return visible;
}

const MAX_STACK_SIZE: u32 = 4096 * 4;

var<workgroup> global_index: atomic<u32>;
var<workgroup> global_count: atomic<u32>;

@compute
@workgroup_size(32, 1, 1)
fn main(
    @builtin(local_invocation_id) local_invocation_id: vec3<u32>, 
    @builtin(local_invocation_index) local_invocation_index: u32, 
    @builtin(global_invocation_id) global_invocation_id: vec3<u32>, 
    @builtin(workgroup_id) workgroup_id: vec3<u32>
) {
    
    atomicStore(&global_count, culling_data.lod0_meshlets_count);
    atomicStore(&commands_count, 0u);
    
    if (local_invocation_id.x >= culling_data.lod0_meshlets_count) {
        return;
    }

    loop
    {
        let index = atomicAdd(&global_index, 1u);        
        if (index >= atomicLoad(&global_count)) {
            atomicSub(&global_index, 1u);             
            break;
        }
         
        let meshlet_id = atomicLoad(&meshlet_culling_data[index]);
        var desired_lod_level = -1;
        if(index > culling_data.lod0_meshlets_count) {             
            desired_lod_level = i32(atomicLoad(&processing_data[meshlet_id]));
        }
         
        let meshlet = meshlets.data[meshlet_id];
        let mesh_id = meshlet.mesh_index_and_lod_level >> 3u;
        let mesh = meshes.data[mesh_id];
        let flags = (mesh.flags_and_vertices_attribute_layout & 0xFFFF0000u) >> 16u;
        if (flags != culling_data.mesh_flags) {   
            return;
        }

        let bb_id = mesh.blas_index + meshlet.bvh_offset;
        let bb = &bhv.data[bb_id];
        let bb_max = transform_vector((*bb).max, mesh.position, mesh.orientation, mesh.scale);
        let bb_min = transform_vector((*bb).min, mesh.position, mesh.orientation, mesh.scale);
        let min = min(bb_min, bb_max);
        let max = max(bb_min, bb_max);

        let clip_mvp = constant_data.proj * culling_data.view;
        let row0 = matrix_row(clip_mvp, 0u);
        let row1 = matrix_row(clip_mvp, 1u);
        let row3 = matrix_row(clip_mvp, 3u);
        var frustum: array<vec4<f32>, 4>;
        frustum[0] = normalize_plane(row3 + row0);
        frustum[1] = normalize_plane(row3 - row0);
        frustum[2] = normalize_plane(row3 + row1);
        frustum[3] = normalize_plane(row3 - row1);
        if !is_box_inside_frustum(min, max, frustum) {
            return;
        }

        //Evaluate cam distance to decide if lod is ok to use for this meshlet or to use childrens
        if(desired_lod_level < 0) {
            //let min_distance = clip_to_world(vec2<f32>(0.), 0.);
            //let max_distance = clip_to_world(vec2<f32>(0.), 1.);
            //let total_distance = length(max_distance - min_distance) * 0.25;
            //let distance = length(min - culling_data.view[3].xyz);
            //let distance_lod_level = u32(max((1. - (length(distance - min_distance) / total_distance)) * f32(MAX_LOD_LEVELS), 0.0));

            var ncd_min = clip_mvp * vec4<f32>(min, 1.);
            let screen_min = clip_to_normalized(ncd_min.xy / ncd_min.w);
            var ncd_max = clip_mvp * vec4<f32>(max, 1.);
            let screen_max = clip_to_normalized(ncd_max.xy / ncd_max.w);
            let screen_diff = max(screen_max, screen_min) - min(screen_max, screen_min);
            let screen_size = saturate(max(screen_diff.x, screen_diff.y));
            let size_lod_level = min(u32(max(screen_size * (f32(MAX_LOD_LEVELS) * 1.25), 0.0)), MAX_LOD_LEVELS - 1u);
            desired_lod_level = i32(size_lod_level);
        }
        if (constant_data.forced_lod_level >= 0) {
            desired_lod_level = i32(MAX_LOD_LEVELS - 1 - u32(constant_data.forced_lod_level));
        }

        let meshlet_lod_level = meshlet.mesh_index_and_lod_level & 7u;
        let lod_level = u32(desired_lod_level);
        if(meshlet_lod_level < lod_level) {  
            if(meshlet.child_meshlets.x >= 0) {                 
                let result = atomicCompareExchangeWeak(&processing_data[meshlet.child_meshlets.x], 0u, lod_level);
                if(result.exchanged) {
                    let child_index = atomicAdd(&global_count, 1u);
                    atomicStore(&meshlet_culling_data[child_index], u32(meshlet.child_meshlets.x));
                }
            }  
            if(meshlet.child_meshlets.y >= 0) {                 
                let result = atomicCompareExchangeWeak(&processing_data[meshlet.child_meshlets.y], 0u, lod_level);
                if(result.exchanged) {                     
                    let child_index = atomicAdd(&global_count, 1u);                     
                    atomicStore(&meshlet_culling_data[child_index], u32(meshlet.child_meshlets.y));                     
                }
            }  
            if(meshlet.child_meshlets.z >= 0) {                 
                let result = atomicCompareExchangeWeak(&processing_data[meshlet.child_meshlets.z], 0u, lod_level);
                if(result.exchanged) {                     
                    let child_index = atomicAdd(&global_count, 1u);                     
                    atomicStore(&meshlet_culling_data[child_index], u32(meshlet.child_meshlets.z));                     
                }
            }  
            if(meshlet.child_meshlets.w >= 0) {                 
                let result = atomicCompareExchangeWeak(&processing_data[meshlet.child_meshlets.w], 0u, lod_level);
                if(result.exchanged) {                     
                    let child_index = atomicAdd(&global_count, 1u);                     
                    atomicStore(&meshlet_culling_data[child_index], u32(meshlet.child_meshlets.w));                     
                }
            }          
        } 
        else 
        {     
            let command_index = atomicAdd(&commands_count, 1u);             
            let command = &commands.data[command_index];
            (*command).vertex_count = meshlet.indices_count;
            (*command).instance_count = 1u;
            (*command).base_index = meshlet.indices_offset;
            (*command).vertex_offset = i32(mesh.vertices_position_offset);
            (*command).base_instance = meshlet_id;
        }
    }    
}
spirv_code  wgsl_code   � const DEFAULT_WIDTH: u32 = 1920u;
const DEFAULT_HEIGHT: u32 = 1080u;
const SIZE_OF_DATA_BUFFER_ELEMENT: u32 = 4u;
const MAX_LOD_LEVELS: u32 = 8u;
const MAX_NUM_LIGHTS: u32 = 1024u;
const MAX_NUM_TEXTURES: u32 = 65536u;
const MAX_NUM_MATERIALS: u32 = 65536u;

const CONSTANT_DATA_FLAGS_NONE: u32 = 0u;
const CONSTANT_DATA_FLAGS_USE_IBL: u32 = 1u;
const CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 1u << 1u;
const CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 1u << 2u;
const CONSTANT_DATA_FLAGS_DISPLAY_RADIANCE_BUFFER: u32 = 1u << 3u;
const CONSTANT_DATA_FLAGS_DISPLAY_DEPTH_BUFFER: u32 = 1u << 4u;
const CONSTANT_DATA_FLAGS_DISPLAY_PATHTRACE: u32 = 1u << 5u;
const CONSTANT_DATA_FLAGS_DISPLAY_NORMALS: u32 = 1u << 6u;
const CONSTANT_DATA_FLAGS_DISPLAY_TANGENT: u32 = 1u << 7u;
const CONSTANT_DATA_FLAGS_DISPLAY_BITANGENT: u32 = 1u << 8u;
const CONSTANT_DATA_FLAGS_DISPLAY_BASE_COLOR: u32 = 1u << 9u;
const CONSTANT_DATA_FLAGS_DISPLAY_METALLIC: u32 = 1u << 10u;
const CONSTANT_DATA_FLAGS_DISPLAY_ROUGHNESS: u32 = 1u << 11u;
const CONSTANT_DATA_FLAGS_DISPLAY_UV_0: u32 = 1u << 12u;
const CONSTANT_DATA_FLAGS_DISPLAY_UV_1: u32 = 1u << 13u;
const CONSTANT_DATA_FLAGS_DISPLAY_UV_2: u32 = 1u << 14u;
const CONSTANT_DATA_FLAGS_DISPLAY_UV_3: u32 = 1u << 15u;

const MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;
const MAX_TEXTURE_COORDS_SET: u32 = 4u;

const TEXTURE_TYPE_BASE_COLOR: u32 = 0u;
const TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;
const TEXTURE_TYPE_NORMAL: u32 = 2u;
const TEXTURE_TYPE_EMISSIVE: u32 = 3u;
const TEXTURE_TYPE_OCCLUSION: u32 = 4u;
const TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;
const TEXTURE_TYPE_DIFFUSE: u32 = 6u;
const TEXTURE_TYPE_SPECULAR: u32 = 7u;
const TEXTURE_TYPE_SPECULAR_COLOR: u32 = 8u;
const TEXTURE_TYPE_TRANSMISSION: u32 = 9u;
const TEXTURE_TYPE_THICKNESS: u32 = 10u;
const TEXTURE_TYPE_EMPTY_FOR_PADDING_3: u32 = 11u;
const TEXTURE_TYPE_EMPTY_FOR_PADDING_4: u32 = 12u;
const TEXTURE_TYPE_EMPTY_FOR_PADDING_5: u32 = 13u;
const TEXTURE_TYPE_EMPTY_FOR_PADDING_6: u32 = 14u;
const TEXTURE_TYPE_EMPTY_FOR_PADDING_7: u32 = 15u;
const TEXTURE_TYPE_COUNT: u32 = 16u;

const MATERIAL_ALPHA_BLEND_OPAQUE = 0u;
const MATERIAL_ALPHA_BLEND_MASK = 1u;
const MATERIAL_ALPHA_BLEND_BLEND = 2u;

const MESH_FLAGS_NONE: u32 = 0u;
const MESH_FLAGS_VISIBLE: u32 = 1u;
const MESH_FLAGS_OPAQUE: u32 = 1u << 1u;
const MESH_FLAGS_TRANSPARENT: u32 = 1u << 2u;
const MESH_FLAGS_WIREFRAME: u32 = 1u << 3u;
const MESH_FLAGS_DEBUG: u32 = 1u << 4u;
const MESH_FLAGS_UI: u32 = 1u << 5u;


const MATH_PI: f32 = 3.14159265359;
const MATH_EPSILON = 0.0000001;
const MAX_FLOAT: f32 = 3.402823466e+38;
const MAX_TRACING_DISTANCE: f32 = 500.;
const HIT_EPSILON: f32 = 0.0001;
const INVALID_NODE: i32 = -1;

const VERTEX_ATTRIBUTE_HAS_POSITION: u32 = 0u;
const VERTEX_ATTRIBUTE_HAS_COLOR: u32 = 1u;
const VERTEX_ATTRIBUTE_HAS_NORMAL: u32 = 1u << 1u;
const VERTEX_ATTRIBUTE_HAS_TANGENT: u32 = 1u << 2u;
const VERTEX_ATTRIBUTE_HAS_UV1: u32 = 1u << 3u;
const VERTEX_ATTRIBUTE_HAS_UV2: u32 = 1u << 4u;
const VERTEX_ATTRIBUTE_HAS_UV3: u32 = 1u << 5u;
const VERTEX_ATTRIBUTE_HAS_UV4: u32 = 1u << 6u;

const MATERIAL_FLAGS_NONE: u32 = 0u;
const MATERIAL_FLAGS_UNLIT: u32 = 1u;
const MATERIAL_FLAGS_IRIDESCENCE: u32 = 1u << 1u;
const MATERIAL_FLAGS_ANISOTROPY: u32 = 1u << 2u;
const MATERIAL_FLAGS_CLEARCOAT: u32 = 1u << 3u;
const MATERIAL_FLAGS_SHEEN: u32 = 1u << 4u;
const MATERIAL_FLAGS_TRANSMISSION: u32 = 1u << 5u;
const MATERIAL_FLAGS_VOLUME: u32 = 1u << 6u;
const MATERIAL_FLAGS_EMISSIVE_STRENGTH: u32 = 1u << 7u;
const MATERIAL_FLAGS_METALLICROUGHNESS: u32 = 1u << 8u;
const MATERIAL_FLAGS_SPECULAR: u32 = 1u << 9u;
const MATERIAL_FLAGS_SPECULARGLOSSINESS: u32 = 1u << 10u;
const MATERIAL_FLAGS_IOR: u32 = 1u << 11u;
const MATERIAL_FLAGS_ALPHAMODE_OPAQUE: u32 = 1u << 12u;
const MATERIAL_FLAGS_ALPHAMODE_MASK: u32 = 1u << 13u;
const MATERIAL_FLAGS_ALPHAMODE_BLEND: u32 = 1u << 14u;

const LIGHT_TYPE_INVALID: u32 = 0u;
const LIGHT_TYPE_DIRECTIONAL: u32 = 1u;
const LIGHT_TYPE_POINT: u32 = 1u << 1u;
const LIGHT_TYPE_SPOT: u32 = 1u << 2u;

struct ConstantData {
    view: mat4x4<f32>,
    inv_view: mat4x4<f32>,
    proj: mat4x4<f32>,
    view_proj: mat4x4<f32>,
    inverse_view_proj: mat4x4<f32>,
    screen_width: f32,
    screen_height: f32,
    frame_index: u32,
    flags: u32,
    debug_uv_coords: vec2<f32>,
    tlas_starting_index: u32,
    indirect_light_num_bounces: u32,
    lut_pbr_charlie_texture_index: u32,
    lut_pbr_ggx_texture_index: u32,
    environment_map_texture_index: u32,
    num_lights: u32,
    forced_lod_level: i32,
    camera_near: f32,
    camera_far: f32,
    _empty3: u32,
};

struct RuntimeVertexData {
    @location(0) world_pos: vec3<f32>,
    @location(1) @interpolate(flat) mesh_index: u32,
};

struct DrawCommand {
    vertex_count: u32,
    instance_count: u32,
    base_vertex: u32,
    base_instance: u32,
};

struct DrawIndexedCommand {
    vertex_count: u32,
    instance_count: u32,
    base_index: u32,
    vertex_offset: i32,
    base_instance: u32,
};

struct DispatchCommandSize {
    x: atomic<u32>,
    y: atomic<u32>,
    z: atomic<u32>,
};

struct Mesh {
    vertices_position_offset: u32,
    vertices_attribute_offset: u32,
    flags_and_vertices_attribute_layout: u32,
    material_index: i32,
    orientation: vec4<f32>,
    position: vec3<f32>,
    meshlets_offset: u32,
    scale: vec3<f32>,
    blas_index: u32,
    lods_meshlets_offset: array<u32, MAX_LOD_LEVELS>,
};

struct Meshlet {
    @location(5) mesh_index_and_lod_level: u32, // 29 mesh + 3 lod bits
    @location(6) indices_offset: u32,
    @location(7) indices_count: u32,
    @location(8) bvh_offset: u32,
    @location(9) child_meshlets: vec4<i32>,
};

struct BHVNode {
    min: vec3<f32>,
    miss: i32,
    max: vec3<f32>,
    reference: i32, //-1 or mesh_index or meshlet_index or triangle_index
};


struct LightData {
    position: vec3<f32>,
    light_type: u32,
    direction: vec3<f32>,
    intensity: f32,
    color: vec3<f32>,
    range: f32,
    inner_cone_angle: f32,
    outer_cone_angle: f32,
    _padding1: f32,
    _padding2: f32,
};

struct TextureData {
    texture_and_layer_index: i32,
    min: u32,
    max: u32,
    size: u32,
};

struct Material {
    roughness_factor: f32,
    metallic_factor: f32,
    ior: f32,
    transmission_factor: f32,
    base_color: vec4<f32>,
    emissive_color: vec3<f32>,
    emissive_strength: f32,
    diffuse_color: vec4<f32>,
    specular_color: vec4<f32>,
    specular_factors: vec4<f32>,
    attenuation_color_and_distance: vec4<f32>,
    thickness_factor: f32,
    normal_scale_and_alpha_cutoff: u32,
    occlusion_strength: f32,
    flags: u32,
    textures_index_and_coord_set: array<u32, TEXTURE_TYPE_COUNT>,
};


struct Lights {
    data: array<LightData, MAX_NUM_LIGHTS>,
};

struct Textures {
    data: array<TextureData>,
};

struct Materials {
    data: array<Material>,
};

struct DrawCommands {
    data: array<DrawCommand>,
};

struct DrawIndexedCommands {
    data: array<DrawIndexedCommand>,
};

struct Meshes {
    data: array<Mesh>,
};

struct Meshlets {
    data: array<Meshlet>,
};

struct Indices {
    data: array<u32>,
};

struct RuntimeVertices {
    data: array<RuntimeVertexData>,
};

struct VerticesPositions {
    data: array<u32>,
};

struct VerticesAttributes {
    data: array<u32>,
};

struct BHV {
    data: array<BHVNode>,
};


struct Ray {
    origin: vec3<f32>,
    t_min: f32,
    direction: vec3<f32>,
    t_max: f32,
};

struct PixelData {
    world_pos: vec3<f32>,
    material_id: u32,
    color: vec4<f32>,
    normal: vec3<f32>,
    mesh_id: u32, 
    tangent: vec4<f32>,
    uv_set: array<vec4<f32>, 4>,
};

struct TBN {
    normal: vec3<f32>,
    tangent: vec3<f32>,
    binormal: vec3<f32>,
};

struct MaterialInfo {
    base_color: vec4<f32>,

    f0: vec3<f32>,
    ior: f32,

    c_diff: vec3<f32>,
    perceptual_roughness: f32,

    metallic: f32,
    specular_weight_and_anisotropy_strength: u32,
    transmission_factor: f32,
    thickness_factor: f32,

    attenuation_color_and_distance: vec4<f32>,
    sheen_color_and_roughness_factor: vec4<f32>,

    clear_coat_f0: vec3<f32>,
    clear_coat_factor: f32,

    clear_coat_f90: vec3<f32>,
    clear_coat_roughness_factor: f32,

    clear_coat_normal: vec3<f32>,
    iridescence_factor: f32,

    anisotropicT: vec3<f32>,
    iridescence_ior: f32,

    anisotropicB: vec3<f32>,
    iridescence_thickness: f32,

    alpha_roughness: f32,
    f90: vec3<f32>,
    
    f_color: vec4<f32>,
    f_emissive: vec3<f32>,
    f_diffuse: vec3<f32>,
    f_diffuse_ibl: vec3<f32>,
    f_specular: vec3<f32>,
};
fn quantize_unorm(v: f32, n: u32) -> u32 {
    let scale = f32((1u << n) - 1u);
    return u32(0.5 + (v * scale));
}
fn quantize_snorm(v: f32, n: u32) -> u32 {
    let c = (1u << (n - 1u)) - 1u;
    let scale = f32(c);
    if v < 0. {
        return (u32(-v * scale) & c) | (1u << (n - 1u));
    } else {
        return u32(v * scale) & c;
    }
}

fn decode_unorm(i: u32, n: u32) -> f32 {    
    let scale = f32((1u << n) - 1u);
    if (i == 0u) {
        return 0.;
    } else if (i == u32(scale)) {
        return 1.;
    } else {
        return (f32(i) - 0.5) / scale;
    }
}

fn decode_snorm(i: u32, n: u32) -> f32 {
    let s = i >> (n - 1u);
    let c = (1u << (n - 1u)) - 1u;
    let scale = f32(c);
    if s > 0u {
        let r = f32(i & c) / scale;
        return -r;
    } else {
        return f32(i & c) / scale;
    }
}

fn pack_3_f32_to_unorm(value: vec3<f32>) -> u32 {
    let x = quantize_unorm(value.x, 10u) << 20u;
    let y = quantize_unorm(value.y, 10u) << 10u;
    let z = quantize_unorm(value.z, 10u);
    return (x | y | z);
}
fn unpack_unorm_to_3_f32(v: u32) -> vec3<f32> {
    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);
    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);
    let vz = decode_unorm(v & 0x000003FFu, 10u);
    return vec3<f32>(vx, vy, vz);
}

fn pack_3_f32_to_snorm(value: vec3<f32>) -> u32 {
    let x = quantize_snorm(value.x, 10u) << 20u;
    let y = quantize_snorm(value.y, 10u) << 10u;
    let z = quantize_snorm(value.z, 10u);
    return (x | y | z);
}
fn unpack_snorm_to_3_f32(v: u32) -> vec3<f32> {
    let vx = decode_snorm((v >> 20u) & 0x000003FFu, 10u);
    let vy = decode_snorm((v >> 10u) & 0x000003FFu, 10u);
    let vz = decode_snorm(v & 0x000003FFu, 10u);
    return vec3<f32>(vx, vy, vz);
}

fn unpack_normal(f: f32) -> vec3<f32> {
	var f_var = f;
	var flipZ: f32 = sign(f_var);
	f_var = abs(f_var);
	let atanXY: f32 = floor(f_var) / 67.5501 * (3.1415927 * 2.) - 3.1415927;
	var n: vec3<f32> = vec3<f32>(sin(atanXY), cos(atanXY), 0.);
	n.z = fract(f_var) * 1869.2296 / 427.67993;
	n = normalize(n);
	n.z = n.z * (flipZ);
	return n;
} 

fn pack_normal(n: vec3<f32>) -> f32 {
	var n_var = n;
	let flipZ: f32 = sign(n_var.z);
	n_var.z = abs(n_var.z);
	n_var = n_var / (23.065746);
	let xy: f32 = floor((atan2(n_var.x, n_var.y) + 3.1415927) / (3.1415927 * 2.) * 67.5501);
	var z: f32 = floor(n_var.z * 427.67993) / 1869.2296;
	z = z * (1. / max(0.01, length(vec2<f32>(n_var.x, n_var.y))));
	return (xy + z) * flipZ;
} 


fn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {
    let r = quantize_unorm(value.x, 8u) << 24u;
    let g = quantize_unorm(value.y, 8u) << 16u;
    let b = quantize_unorm(value.z, 8u) << 8u;
    let a = quantize_unorm(value.w, 8u);
    return (r | g | b | a);
}
fn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {
    let r = decode_snorm((v >> 24u) & 255u, 8u);
    let g = decode_snorm((v >> 16u) & 255u, 8u);
    let b = decode_snorm((v >> 8u) & 255u, 8u);
    let a = decode_snorm(v & 255u, 8u);
    return vec4<f32>(r,g,b,a);
}
fn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {
    let r = decode_unorm((v >> 24u) & 255u, 8u);
    let g = decode_unorm((v >> 16u) & 255u, 8u);
    let b = decode_unorm((v >> 8u) & 255u, 8u);
    let a = decode_unorm(v & 255u, 8u);
    return vec4<f32>(r,g,b,a);
}

fn sign_not_zero(v: vec2<f32>) -> vec2<f32> {
	return vec2<f32>(select(-1., 1., v.x >= 0.), select(-1., 1., v.y >= 0.));
} 

fn octahedral_mapping(v: vec3<f32>) -> vec2<f32> {
	let l1norm: f32 = abs(v.x) + abs(v.y) + abs(v.z);
	var result: vec2<f32> = v.xy * (1. / l1norm);
	if (v.z < 0.) {
		result = (1. - abs(result.yx)) * sign_not_zero(result.xy);
	}
	return result;
} 

fn octahedral_unmapping(o: vec2<f32>) -> vec3<f32> {
	var v: vec3<f32> = vec3<f32>(o.x, o.y, 1. - abs(o.x) - abs(o.y));
	if (v.z < 0.) {
		var vxy = v.xy;
        vxy = (1. - abs(v.yx)) * sign_not_zero(v.xy);
        v.x = vxy.x;
        v.y = vxy.y;
	}
	return normalize(v);
} 

fn f32tof16(v: f32) -> u32 {
    return pack2x16float(vec2<f32>(v, 0.));
}

fn f16tof32(v: u32) -> f32 {
    return unpack2x16float(v & 0x0000FFFFu).x;
}

fn pack_into_R11G11B10F(rgb: vec3<f32>) -> u32 {
	let r = (f32tof16(rgb.r) << 17u) & 0xFFE00000u;
	let g = (f32tof16(rgb.g) << 6u) & 0x001FFC00u;
	let b = (f32tof16(rgb.b) >> 5u) & 0x000003FFu;
	return r | g | b;
} 

fn unpack_from_R11G11B10F(rgb: u32) -> vec3<f32> {
	let r = f16tof32((rgb >> 17u) & 0x7FF0u);
	let g = f16tof32((rgb >> 6u) & 0x7FF0u);
	let b = f16tof32((rgb << 5u) & 0x7FE0u);
	return vec3<f32>(r, g, b);
} 


fn iq_hash(v: vec2<f32>) -> f32 {
    return fract(sin(dot(v, vec2(11.9898, 78.233))) * 43758.5453);
}
fn blue_noise(in: vec2<f32>) -> f32 {
    var v =  iq_hash( in + vec2<f32>(-1., 0.) )
             + iq_hash( in + vec2<f32>( 1., 0.) )
             + iq_hash( in + vec2<f32>( 0., 1.) )
             + iq_hash( in + vec2<f32>( 0.,-1.) ); 
    v /= 4.;
    return (iq_hash(in) - v + .5);
}

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
fn hash( x: u32 ) -> u32 {
    var v = x;
    v += ( v << 10u );
    v ^= ( v >>  6u );
    v += ( v <<  3u );
    v ^= ( v >> 11u );
    v += ( v << 15u );
    return v;
}

fn hash1(seed: f32) -> f32 {
    var p = fract(seed * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

fn hash2(seed: ptr<function, f32>) -> vec2<f32> {
    let a = (*seed) + 0.1;
    let b = a + 0.1;
    (*seed) = b;
    return fract(sin(vec2(a,b))*vec2(43758.5453123,22578.1459123));
}

fn hash3(seed: ptr<function, f32>) -> vec3<f32> {
    let a = (*seed) + 0.1;
    let b = a + 0.1;
    let c = b + 0.1;
    (*seed) = c;
    return fract(sin(vec3(a,b,c))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

// This is PCG2d
fn get_random_numbers(seed: ptr<function, vec2<u32>>) -> vec2<f32> {
    var v = (*seed) * 1664525u + 1013904223u;
    v.x += v.y * 1664525u; v.y += v.x * 1664525u;
    v ^= v >> vec2u(16u);
    v.x += v.y * 1664525u; v.y += v.x * 1664525u;
    v ^= v >> vec2u(16u);
    *seed = v;
    return vec2<f32>(v) * 2.32830643654e-10;
}

fn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) 
{
    let c = *ptr_a;
    *ptr_a = *ptr_b;
    *ptr_b = c;
}

fn mod_f32(v: f32, m: f32) -> f32
{
    return v - (m * floor(v/m));
}

fn clamped_dot(a: vec3<f32>, b: vec3<f32>) -> f32 {
    return clamp(dot(a,b), 0., 1.);
}

fn has_vertex_attribute(vertex_attribute_layout: u32, attribute_to_check: u32) -> bool {
    return bool(vertex_attribute_layout & attribute_to_check);
}
fn vertex_attribute_offset(vertex_attribute_layout: u32, attribute_to_check: u32) -> i32 
{
    if(has_vertex_attribute(vertex_attribute_layout, attribute_to_check)) {
        let mask = (vertex_attribute_layout & 0x0000FFFFu) & (~attribute_to_check & (attribute_to_check - 1u));
        return i32(countOneBits(mask));
    }
    return -1;
}
fn vertex_layout_stride(vertex_attribute_layout: u32) -> u32 
{
    return countOneBits((vertex_attribute_layout & 0x0000FFFFu));
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) uv: vec2<f32>,
};

struct FragmentOutput {
    @location(0) color: vec4<f32>,
};


@group(0) @binding(0)
var<uniform> constant_data: ConstantData;
@group(0) @binding(1)
var<storage, read> indices: Indices;
@group(0) @binding(2)
var<storage, read> runtime_vertices: RuntimeVertices;
@group(0) @binding(3)
var<storage, read> vertices_attributes: VerticesAttributes;
@group(0) @binding(4)
var<storage, read> meshes: Meshes;
@group(0) @binding(5)
var<storage, read> meshlets: Meshlets;

@group(1) @binding(0)
var<storage, read> materials: Materials;
@group(1) @binding(1)
var<storage, read> textures: Textures;
@group(1) @binding(2)
var<uniform> lights: Lights;
@group(1) @binding(3)
var visibility_texture: texture_multisampled_2d<u32>;
@group(1) @binding(4)
var depth_texture: texture_depth_multisampled_2d;

@group(3) @binding(0)
var<storage, read> data_buffer_0: array<f32>;
@group(3) @binding(1)
var<storage, read> data_buffer_1: array<f32>;
@group(3) @binding(2)
var<storage, read> data_buffer_2: array<f32>;
@group(3) @binding(3)
var<storage, read> data_buffer_3: array<f32>;
@group(3) @binding(4)
var<storage, read> data_buffer_4: array<f32>;
@group(3) @binding(5)
var<storage, read> data_buffer_5: array<f32>;
@group(3) @binding(6)
var<storage, read> data_buffer_6: array<f32>;
@group(3) @binding(7)
var<storage, read> data_buffer_debug: array<f32>;

@group(2) @binding(0)
var default_sampler: sampler;

@group(2) @binding(1)
var texture_1: texture_2d_array<f32>;
@group(2) @binding(2)
var texture_2: texture_2d_array<f32>;
@group(2) @binding(3)
var texture_3: texture_2d_array<f32>;
@group(2) @binding(4)
var texture_4: texture_2d_array<f32>;
@group(2) @binding(5)
var texture_5: texture_2d_array<f32>;
@group(2) @binding(6)
var texture_6: texture_2d_array<f32>;
@group(2) @binding(7)
var texture_7: texture_2d_array<f32>;


fn sample_texture(tex_coords_and_texture_index: vec3<f32>) -> vec4<f32> {
    let texture_data_index = i32(tex_coords_and_texture_index.z);
    var v = vec4<f32>(0.);
    var tex_coords = vec3<f32>(0.0, 0.0, 0.0);
    if (texture_data_index < 0) {
        return v;
    }
    let texture = &textures.data[texture_data_index];
    var texture_index = (*texture).texture_and_layer_index;
    let area_start = unpack2x16float((*texture).min);
    let area_size = unpack2x16float((*texture).max);
    let total_size = unpack2x16float((*texture).size);
    if (texture_index < 0) {
        texture_index *= -1;
    } 
    let atlas_index = u32(texture_index >> 3);
    let layer_index = i32(texture_index & 0x00000007);

    tex_coords.x = (f32(area_start.x) + mod_f32(tex_coords_and_texture_index.x, 1.) * f32(area_size.x)) / f32(total_size.x);
    tex_coords.y = (f32(area_start.y) + mod_f32(tex_coords_and_texture_index.y, 1.) * f32(area_size.y)) / f32(total_size.y);
    tex_coords.z = f32(layer_index);

    switch (atlas_index) {
        case 0u: { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }
        case 1u: { v = textureSampleLevel(texture_2, default_sampler, tex_coords.xy, layer_index, 0.); }
        case 2u: { v = textureSampleLevel(texture_3, default_sampler, tex_coords.xy, layer_index, 0.); }
        case 3u: { v = textureSampleLevel(texture_4, default_sampler, tex_coords.xy, layer_index, 0.); }
        case 4u: { v = textureSampleLevel(texture_5, default_sampler, tex_coords.xy, layer_index, 0.); }
        case 5u: { v = textureSampleLevel(texture_6, default_sampler, tex_coords.xy, layer_index, 0.); }
        case 6u: { v = textureSampleLevel(texture_7, default_sampler, tex_coords.xy, layer_index, 0.); }
        default { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }
    };
    return v;
}

struct Derivatives {
    dx: vec3<f32>,
    dy: vec3<f32>,
}

fn pixel_to_normalized(image_pixel: vec2<u32>, image_size: vec2<u32>) -> vec2<f32> {
    return ((vec2<f32>(0.5) + vec2<f32>(image_pixel)) / vec2<f32>(image_size));
}
fn clip_to_normalized(clip_coords: vec2<f32>) -> vec2<f32> {
    return (clip_coords + vec2<f32>(1.)) * vec2<f32>(0.5);
}

fn pixel_to_clip(image_pixel: vec2<u32>, image_size: vec2<u32>) -> vec2<f32> {
    var clip_coords = 2. * pixel_to_normalized(image_pixel, image_size) - vec2<f32>(1.);
    clip_coords.y *= -1.;
    return clip_coords;
}

fn pixel_to_world(image_pixel: vec2<u32>, image_size: vec2<u32>, depth: f32) -> vec3<f32> {
    let clip_coords = pixel_to_clip(image_pixel, image_size);
    let world_pos = clip_to_world(clip_coords, depth);
    return world_pos;
}

fn clip_to_world(clip_coords: vec2<f32>, depth: f32) -> vec3<f32> {    
    var world_pos = constant_data.inverse_view_proj * vec4<f32>(clip_coords, depth, 1.);
    world_pos /= world_pos.w;
    return world_pos.xyz;
}

fn world_to_clip(world_pos: vec3<f32>) -> vec3<f32> {    
	let ndc_pos: vec4<f32> = constant_data.view_proj * vec4<f32>(world_pos, 1.);
	return ndc_pos.xyz / ndc_pos.w;
}

fn view_pos() -> vec3<f32> {    
    return clip_to_world(vec2<f32>(0.), 0.);
}

fn compute_barycentrics_3d(p1: vec3<f32>, p2: vec3<f32>, p3: vec3<f32>, p: vec3<f32>) -> vec3<f32> {
    let v1 = p - p1;
    let v2 = p - p2;
    let v3 = p - p3;
    
    let area = length(cross(v1 - v2, v1 - v3)); 
    return vec3<f32>(length(cross(v2, v3)) / area, length(cross(v3, v1)) / area, length(cross(v1, v2)) / area); 
}

fn compute_barycentrics_2d(a: vec2<f32>, b: vec2<f32>, c: vec2<f32>, p: vec2<f32>) -> vec3<f32> {
    let v0 = b - a;
    let v1 = c - a;
    let v2 = p - a;
    
    let d00 = dot(v0, v0);    
    let d01 = dot(v0, v1);    
    let d11 = dot(v1, v1);
    let d20 = dot(v2, v0);
    let d21 = dot(v2, v1);
    
    let inv_denom = 1. / (d00 * d11 - d01 * d01);    
    let v = (d11 * d20 - d01 * d21) * inv_denom;    
    let w = (d00 * d21 - d01 * d20) * inv_denom;    
    let u = 1. - v - w;

    return vec3 (u,v,w);
}

// Engel's barycentric coord partial derivs function. Follows equation from [Schied][Dachsbacher]
// Computes the partial derivatives of point's barycentric coordinates from the projected screen space vertices
fn compute_partial_derivatives(v0: vec2<f32>, v1: vec2<f32>, v2: vec2<f32>) -> Derivatives
{
    let d = 1. / determinant(mat2x2<f32>(v2-v1, v0-v1));
    
    return Derivatives(vec3<f32>(v1.y - v2.y, v2.y - v0.y, v0.y - v1.y) * d, vec3<f32>(v2.x - v1.x, v0.x - v2.x, v1.x - v0.x) * d);
}

// Interpolate 2D attributes using the partial derivatives and generates dx and dy for texture sampling.
fn interpolate_2d_attribute(a0: vec2<f32>, a1: vec2<f32>, a2: vec2<f32>, deriv: Derivatives, delta: vec2<f32>) -> vec2<f32>
{
	let attr0 = vec3<f32>(a0.x, a1.x, a2.x);
	let attr1 = vec3<f32>(a0.y, a1.y, a2.y);
	let attribute_x = vec2<f32>(dot(deriv.dx, attr0), dot(deriv.dx, attr1));
	let attribute_y = vec2<f32>(dot(deriv.dy, attr0), dot(deriv.dy, attr1));
	let attribute_s = a0;
	
	return (attribute_s + delta.x * attribute_x + delta.y * attribute_y);
}

// Interpolate vertex attributes at point 'd' using the partial derivatives
fn interpolate_3d_attribute(a0: vec3<f32>, a1: vec3<f32>, a2: vec3<f32>, deriv: Derivatives, delta: vec2<f32>) -> vec3<f32>
{
	let attr0 = vec3<f32>(a0.x, a1.x, a2.x);
	let attr1 = vec3<f32>(a0.y, a1.y, a2.y);
	let attr2 = vec3<f32>(a0.z, a1.z, a2.z);
    let attributes = mat3x3<f32>(a0, a1, a2);
	let attribute_x = attributes * deriv.dx;
	let attribute_y = attributes * deriv.dy;
	let attribute_s = a0;
	
	return (attribute_s + delta.x * attribute_x + delta.y * attribute_y);
}

fn draw_line(uv: vec2<f32>, p1: vec2<f32>, p2: vec2<f32>, width: f32) -> f32 {
    let d = p2 - p1;
    let t = clamp(dot(d,uv-p1) / dot(d,d), 0., 1.);
    let proj = p1 + d * t;
    return 1. - smoothstep(0., width, length(uv - proj));
}

fn draw_circle(uv: vec2<f32>, center: vec2<f32>, radius: f32, width: f32) -> f32 {
    let p = uv - center;
    let d = sqrt(dot(p,p));
    return 1. - smoothstep(0., width, abs(radius-d));
}

fn draw_line_3d(image_pixel: vec2<u32>, image_size: vec2<u32>, start: vec3<f32>, end: vec3<f32>, line_color: vec3<f32>, size: f32) -> vec3<f32>
{    
    let origin = pixel_to_world(image_pixel, image_size, -1.);
    let far = pixel_to_world(image_pixel, image_size, 1.);
    let direction = normalize(far - origin);

    let line_dir = normalize(end-start);
    let v1 = start-origin;
	let d0 = dot(direction, line_dir);
    let d1 = dot(direction, v1);
    let d2 = dot(line_dir, v1);
	var len = (d0*d1-d2)/(1.-d0*d0);
    len = clamp(len, 0., length(end-start));
    let p = start+line_dir*len;
    let value = length(cross(p-origin, direction));
    return mix(line_color, vec3<f32>(0.), 1.-size/value);
}

fn extract_scale(m: mat4x4<f32>) -> vec3<f32> 
{
    let s = mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz);
    let sx = length(s[0]);
    let sy = length(s[1]);
    let det = determinant(s);
    var sz = length(s[2]);
    if (det < 0.) 
    {
        sz = -sz;
    }
    return vec3<f32>(sx, sy, sz);
}

fn matrix_row(m: mat4x4<f32>, row: u32) -> vec4<f32> 
{
    if (row == 1u) {
        return vec4<f32>(m[0].y, m[1].y, m[2].y, m[3].y);
    } else if (row == 2u) {
        return vec4<f32>(m[0].z, m[1].z, m[2].z, m[3].z);
    } else if (row == 3u) {
        return vec4<f32>(m[0].w, m[1].w, m[2].w, m[3].w);
    } else {        
        return vec4<f32>(m[0].x, m[1].x, m[2].x, m[3].x);
    }
}

fn normalize_plane(plane: vec4<f32>) -> vec4<f32> 
{
    return (plane / length(plane.xyz));
}

fn rotate_vector(v: vec3<f32>, orientation: vec4<f32>) -> vec3<f32> 
{
    return v + 2. * cross(orientation.xyz, cross(orientation.xyz, v) + orientation.w * v);
}

fn transform_vector(v: vec3<f32>, position: vec3<f32>, orientation: vec4<f32>, scale: vec3<f32>) -> vec3<f32> 
{
    return rotate_vector(v, orientation) * scale + position;
}

fn matrix_from_translation(translation: vec3<f32>) -> mat4x4<f32> {
    return mat4x4<f32>(vec4<f32>(1.0, 0.0, 0.0, 0.0),
                      vec4<f32>(0.0, 1.0, 0.0, 0.0),
                      vec4<f32>(0.0, 0.0, 1.0, 0.0),
                      vec4<f32>(translation.x, translation.y, translation.z, 1.0));
}

fn matrix_from_scale(scale: vec3<f32>) -> mat4x4<f32> {
    return mat4x4<f32>(vec4<f32>(scale.x, 0.0, 0.0, 0.0),
                      vec4<f32>(0.0, scale.y, 0.0, 0.0),
                      vec4<f32>(0.0, 0.0, scale.z, 0.0),
                      vec4<f32>(0.0, 0.0, 0.0, 1.0));
}

fn matrix_from_orientation(q: vec4<f32>) -> mat4x4<f32> {
    let xx = q.x * q.x;
    let yy = q.y * q.y;
    let zz = q.z * q.z;
    let xy = q.x * q.y;
    let xz = q.x * q.z;
    let yz = q.y * q.z;
    let wx = q.w * q.x;
    let wy = q.w * q.y;
    let wz = q.w * q.z;

    let m00 = 1.0 - 2.0 * (yy + zz);
    let m01 = 2.0 * (xy - wz);
    let m02 = 2.0 * (xz + wy);

    let m10 = 2.0 * (xy + wz);
    let m11 = 1.0 - 2.0 * (xx + zz);
    let m12 = 2.0 * (yz - wx);

    let m20 = 2.0 * (xz - wy);
    let m21 = 2.0 * (yz + wx);
    let m22 = 1.0 - 2.0 * (xx + yy);

    // Utilizza la funzione mat4x4 per creare la matrice 4x4
    return mat4x4<f32>(
        vec4<f32>(m00, m01, m02, 0.0),
        vec4<f32>(m10, m11, m12, 0.0),
        vec4<f32>(m20, m21, m22, 0.0),
        vec4<f32>(0.0, 0.0, 0.0, 1.0)
    );
}

fn transform_matrix(position: vec3<f32>, orientation: vec4<f32>, scale: vec3<f32>) -> mat4x4<f32> {
    let translation_matrix = matrix_from_translation(position);
    let rotation_matrix = matrix_from_orientation(orientation);
    let scale_matrix = matrix_from_scale(scale);    
    return translation_matrix * rotation_matrix * scale_matrix;
}

fn matrix_inverse(m: mat4x4<f32>) -> mat4x4<f32> {
    let a00 = m[0][0]; let a01 = m[0][1]; let a02 = m[0][2]; let a03 = m[0][3];
    let a10 = m[1][0]; let a11 = m[1][1]; let a12 = m[1][2]; let a13 = m[1][3];
    let a20 = m[2][0]; let a21 = m[2][1]; let a22 = m[2][2]; let a23 = m[2][3];
    let a30 = m[3][0]; let a31 = m[3][1]; let a32 = m[3][2]; let a33 = m[3][3];

    let b00 = a00 * a11 - a01 * a10;
    let b01 = a00 * a12 - a02 * a10;
    let b02 = a00 * a13 - a03 * a10;
    let b03 = a01 * a12 - a02 * a11;
    let b04 = a01 * a13 - a03 * a11;
    let b05 = a02 * a13 - a03 * a12;
    let b06 = a20 * a31 - a21 * a30;
    let b07 = a20 * a32 - a22 * a30;
    let b08 = a20 * a33 - a23 * a30;
    let b09 = a21 * a32 - a22 * a31;
    let b10 = a21 * a33 - a23 * a31;
    let b11 = a22 * a33 - a23 * a32;

    let det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
    
    // Ottimizzazione: Calcola l'inverso del determinante una sola volta
    let invDet = 1.0 / det;

    return mat4x4<f32>(
        vec4<f32>((a11 * b11 - a12 * b10 + a13 * b09) * invDet, (a02 * b10 - a01 * b11 - a03 * b09) * invDet, (a31 * b05 - a32 * b04 + a33 * b03) * invDet, (a22 * b04 - a21 * b05 - a23 * b03) * invDet),
        vec4<f32>((a12 * b08 - a10 * b11 - a13 * b07) * invDet, (a00 * b11 - a02 * b08 + a03 * b07) * invDet, (a32 * b02 - a30 * b05 - a33 * b01) * invDet, (a20 * b05 - a22 * b02 + a23 * b01) * invDet),
        vec4<f32>((a10 * b10 - a11 * b08 + a13 * b06) * invDet, (a01 * b08 - a00 * b10 - a03 * b06) * invDet, (a30 * b04 - a31 * b02 + a33 * b00) * invDet, (a21 * b02 - a20 * b04 - a23 * b00) * invDet),
        vec4<f32>((a11 * b07 - a10 * b09 - a12 * b06) * invDet, (a00 * b09 - a01 * b07 + a02 * b06) * invDet, (a31 * b01 - a30 * b03 - a32 * b00) * invDet, (a20 * b03 - a21 * b01 + a22 * b00) * invDet)
    );
}
fn has_texture(material: ptr<function, Material>, texture_type: u32) -> bool {
    let texture_index = (*material).textures_index_and_coord_set[texture_type] & 0x0FFFFFFFu;
    if (texture_index > 0) {
        return true;
    }
    return false;
}

fn material_texture_index(material: ptr<function, Material>, texture_type: u32) -> u32 {
    let texture_index = (*material).textures_index_and_coord_set[texture_type] & 0x0FFFFFFFu;
    return max(0u, texture_index - 1u);
}

fn material_texture_coord_set(material: ptr<function, Material>, texture_type: u32) -> u32 {
    return ((*material).textures_index_and_coord_set[texture_type] & 0xF0000000u) >> 28;
}

fn material_texture_uv(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, texture_type: u32) -> vec3<f32> {
    let texture_coords_set = material_texture_coord_set(material, texture_type);  
    let texture_id = material_texture_index(material, texture_type);
    let uv = vec3<f32>((*pixel_data).uv_set[texture_coords_set].xy, f32(texture_id));
    return uv;
} 

fn compute_tbn(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>) -> TBN {
    var n = (*pixel_data).normal;
    var t = (*pixel_data).tangent.xyz;
    var b = cross(n,  t) * (*pixel_data).tangent.w;
    if (has_texture(material, TEXTURE_TYPE_NORMAL)) {  
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_NORMAL);
        let uv_set_index = material_texture_coord_set(material, TEXTURE_TYPE_NORMAL);
        var ntex = sample_texture(uv).rgb * 2. - vec3<f32>(1.);
        let normal_scale = unpack2x16float((*material).normal_scale_and_alpha_cutoff).x;
        ntex *= vec3<f32>(normal_scale, normal_scale, 1.);
        n = normalize(mat3x3<f32>(t, b, n) * normalize(ntex));
    }
    return TBN(n, t, b);
}

fn init_material_info_default(info: ptr<function, MaterialInfo>) {
    (*info).base_color = vec4<f32>(1.);
    (*info).f0 = vec3<f32>(0.04);
    (*info).ior = 1.5;
    (*info).c_diff = vec3<f32>(1.);
    (*info).perceptual_roughness = 1.;
    (*info).metallic = 1.;
    (*info).specular_weight_and_anisotropy_strength = pack2x16float(vec2<f32>(1., 0.));
    (*info).transmission_factor = 0.;
    (*info).thickness_factor = 0.;
    (*info).attenuation_color_and_distance = vec4<f32>(1.,1.,1.,0.);
    (*info).sheen_color_and_roughness_factor = vec4<f32>(1.,1.,1.,0.);
    (*info).clear_coat_factor = 0.;
    (*info).clear_coat_roughness_factor = 0.;
    (*info).iridescence_ior = 1.3;
    (*info).iridescence_thickness = 100.;
    (*info).alpha_roughness = 0.;
    (*info).f90 = vec3<f32>(1.);

    (*info).f_color = vec4<f32>(0.);
    (*info).f_emissive = vec3<f32>(0.);
    (*info).f_diffuse = vec3<f32>(0.);
    (*info).f_diffuse_ibl = vec3<f32>(0.);
    (*info).f_specular = vec3<f32>(0.);
}

fn compute_base_color(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {
    if(((*material).flags & MATERIAL_FLAGS_SPECULARGLOSSINESS) != 0u) {
        (*info).base_color = (*material).diffuse_color;
        if (has_texture(material, TEXTURE_TYPE_DIFFUSE)) {  
            let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_DIFFUSE);
            let texture_color = sample_texture(uv);
            (*info).base_color *= texture_color;
        }
    } else if(((*material).flags & MATERIAL_FLAGS_UNLIT) != 0u || ((*material).flags & MATERIAL_FLAGS_METALLICROUGHNESS) != 0u) {
        (*info).base_color = (*material).base_color;
        if (has_texture(material, TEXTURE_TYPE_BASE_COLOR)) {  
            let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_BASE_COLOR);
            let texture_color = sample_texture(uv);
            (*info).base_color *= texture_color;
        }
    }
    
    (*info).base_color *= (*pixel_data).color;
    if(((*material).flags & MATERIAL_FLAGS_ALPHAMODE_OPAQUE) != 0) {
        (*info).base_color.a = 1.;
    }
}

fn compute_ior(material: ptr<function, Material>, info: ptr<function, MaterialInfo>) {
    (*info).ior = (*material).ior;
    (*info).f0 = vec3<f32>(pow(( (*info).ior - 1.) /  ((*info).ior + 1.), 2.));
}

fn compute_specular_glossiness(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {
    (*info).f0 = (*material).specular_color.xyz;
    (*info).perceptual_roughness = (*material).specular_color.w;
    if (has_texture(material, TEXTURE_TYPE_SPECULAR_GLOSSINESS)) {  
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_SPECULAR_GLOSSINESS);
        let texture_color = sample_texture(uv);
        (*info).f0 *= texture_color.rgb;
        (*info).perceptual_roughness *= texture_color.a;
    }
    (*info).perceptual_roughness = 1. - (*info).perceptual_roughness;
    (*info).c_diff = (*info).base_color.rgb * (1. - max(max((*info).f0.r, (*info).f0.g), (*info).f0.b));
}

fn compute_metallic_roughness(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {    
    (*info).perceptual_roughness = (*material).roughness_factor;
    (*info).metallic = (*material).metallic_factor;
    if (has_texture(material, TEXTURE_TYPE_METALLIC_ROUGHNESS)) {        
        // Roughness is stored in the 'g' channel, metallic is stored in the 'b' channel.
        // This layout intentionally reserves the 'r' channel for (optional) occlusion map data
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_METALLIC_ROUGHNESS);
        let texture_color = sample_texture(uv);
        (*info).perceptual_roughness *= texture_color.g;
        (*info).metallic *= texture_color.b;
    }
    // Achromatic f0 based on IOR.
    (*info).c_diff = mix((*info).base_color.rgb,  vec3<f32>(0.), (*info).metallic);
    (*info).f0 = mix((*info).f0, (*info).base_color.rgb, (*info).metallic);
}

fn compute_sheen(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {   
    (*info).sheen_color_and_roughness_factor = vec4<f32>(1.,1.,1.,0.);

    //NOT SUPPORTED TILL NOW - need gltf-rs support for KHR_materials_sheen
}

fn compute_clear_coat(material: ptr<function, Material>, normal: vec3<f32>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {   
    (*info).clear_coat_factor = 0.;
    (*info).clear_coat_roughness_factor = 0.;
    (*info).clear_coat_f0 = vec3<f32>(pow(((*info).ior - 1.0) / ((*info).ior + 1.0), 2.0));
    (*info).clear_coat_f90 = vec3<f32>(1.0);
    (*info).clear_coat_normal = normal;
    
    //NOT SUPPORTED TILL NOW - need gltf-rs support for KHR_materials_clearcoat
}

fn compute_specular(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {   
    var specular_texture = vec4<f32>(1.0);
    if (has_texture(material, TEXTURE_TYPE_SPECULAR)) {        
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_SPECULAR);
        let texture_color = sample_texture(uv);
        specular_texture.a = texture_color.a;
    }
    if (has_texture(material, TEXTURE_TYPE_SPECULAR_COLOR)) {        
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_SPECULAR_COLOR);
        let texture_color = sample_texture(uv);
        specular_texture = vec4<f32>(texture_color.rgb, specular_texture.a);
    }
    let dielectric_specular_f0 = min((*info).f0 * (*material).specular_factors.rgb * specular_texture.rgb, vec3<f32>(1.));
    let anisotropy_strength = unpack2x16float((*info).specular_weight_and_anisotropy_strength).y;
    (*info).specular_weight_and_anisotropy_strength = pack2x16float(vec2<f32>((*material).specular_factors.a * specular_texture.a, anisotropy_strength));
    (*info).f0 = mix(dielectric_specular_f0, (*info).base_color.rgb, (*info).metallic);
    (*info).c_diff = mix((*info).base_color.rgb, vec3<f32>(0.), (*info).metallic);
}

fn compute_transmission(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {   
    (*info).transmission_factor = (*material).transmission_factor;
    if (has_texture(material, TEXTURE_TYPE_TRANSMISSION)) {        
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_TRANSMISSION);
        let texture_color = sample_texture(uv);
        (*info).transmission_factor *= texture_color.r;
    }
}

fn compute_volume(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {   
    (*info).thickness_factor = (*material).thickness_factor;
    (*info).attenuation_color_and_distance = (*material).attenuation_color_and_distance;
    if (has_texture(material, TEXTURE_TYPE_THICKNESS)) {        
        let uv = material_texture_uv(material, pixel_data, TEXTURE_TYPE_THICKNESS);
        let texture_color = sample_texture(uv);
        (*info).thickness_factor *= texture_color.g;
    }
}

fn compute_iridescence(material: ptr<function, Material>, pixel_data: ptr<function, PixelData>, info: ptr<function, MaterialInfo>) {  
    (*info).iridescence_factor = 0.;
    (*info).iridescence_ior = (*info).ior;
    (*info).iridescence_thickness = 0.;

    //NOT SUPPORTED TILL NOW - need gltf-rs support for KHR_materials_iridescence 
}

fn compute_anisotropy(material: ptr<function, Material>, tbn: ptr<function, TBN>, info: ptr<function, MaterialInfo>) { 
    let specular_weight = unpack2x16float((*info).specular_weight_and_anisotropy_strength).x;
    (*info).anisotropicT = (*tbn).tangent;
    (*info).anisotropicB = (*tbn).binormal;
    (*info).specular_weight_and_anisotropy_strength = pack2x16float(vec2<f32>(specular_weight, 0.));

    //NOT SUPPORTED TILL NOW - need gltf-rs support for KHR_materials_anisotropy
}
// Inspired from https://github.com/KhronosGroup/glTF-Sample-Viewer

// XYZ to sRGB color space
const XYZ_TO_REC709: mat3x3<f32> = mat3x3<f32>(
     3.2404542, -0.9692660,  0.0556434,
    -1.5371385,  1.8760108, -0.2040259,
    -0.4985314,  0.0415560,  1.0572252
);

fn compute_equirectangular_uv(rd: vec3<f32>) -> vec2<f32> {
    //radial azmuth polar
    let v = vec2<f32>(atan2(rd.z, rd.x) + MATH_PI, acos(rd.y));
    return v / vec2<f32>(2. * MATH_PI, MATH_PI);
}

// Assume air interface for top
// Note: We don't handle the case fresnel0 == 1
fn fresnel0_to_ior(fresnel0: vec3<f32>) -> vec3<f32> {
    let sqrtF0 = sqrt(fresnel0);
    return (vec3<f32> (1.0) + sqrtF0) / (vec3<f32> (1.0) - sqrtF0);
}

// Conversion FO/IOR
fn ior_to_fresnel0_vec3(transmittedIor: vec3<f32>, incidentIor: f32) -> vec3<f32>{
    let ior = (transmittedIor - vec3<f32>(incidentIor)) / (transmittedIor + vec3<f32>(incidentIor));
    return ior * ior;
}

// ior is a value between 1.0 and 3.0. 1.0 is air interface
fn ior_to_fresnel0_f32(transmittedIor: f32, incidentIor: f32) -> f32 {
    let ior = (transmittedIor - incidentIor) / (transmittedIor + incidentIor);
    return ior * ior;
}

fn apply_ior_to_roughness(roughness: f32, ior: f32) -> f32 {
    // Scale roughness with IOR so that an IOR of 1.0 results in no microfacet refraction and
    // an IOR of 1.5 results in the default amount of microfacet refraction.
    return roughness * clamp(ior * 2.0 - 2.0, 0.0, 1.0);
}

fn f_schlick_f32(f0: f32, f90: f32, VdotH: f32) -> f32 {
    let x = clamp(1.0 - VdotH, 0.0, 1.0);
    let x2 = x * x;
    let x5 = x * x2 * x2;
    return f0 + (f90 - f0) * x5;
}

fn f_schlick_vec3_f32(f0: vec3<f32>, f90: f32, VdotH: f32) -> vec3<f32>
{
    let x = clamp(1.0 - VdotH, 0.0, 1.0);
    let x2 = x * x;
    let x5 = x * x2 * x2;
    return f0 + (f90 - f0) * x5;
}

fn f_schlick_vec3_vec3(f0: vec3<f32>, f90: vec3<f32>, VdotH: f32) -> vec3<f32>
{
    return f0 + (f90 - f0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);
}

fn schlick_to_f0_vec3(f: vec3<f32>, f90: vec3<f32>, VdotH: f32) -> vec3<f32> {
    let x = clamp(1.0 - VdotH, 0.0, 1.0);
    let x2 = x * x;
    let x5 = clamp(x * x2 * x2, 0.0, 0.9999);
    let r = (f - (f90 * x5));
    return (r / (1.0 - x5));
}

// Smith Joint GGX
// Note: Vis = G / (4 * NdotL * NdotV)
// see Eric Heitz. 2014. Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs. Journal of Computer Graphics Techniques, 3
// see Real-Time Rendering. Page 331 to 336.
// see https://google.github.io/filament/Filament.md.html#materialsystem/specularbrdf/geometricshadowing(specularg)
fn V_GGX(NdotL: f32, NdotV: f32, alphaRoughness: f32) -> f32 {
    let alphaRoughnessSq = alphaRoughness * alphaRoughness;

    let GGXV = NdotL * sqrt(NdotV * NdotV * (1.0 - alphaRoughnessSq) + alphaRoughnessSq);
    let GGXL = NdotV * sqrt(NdotL * NdotL * (1.0 - alphaRoughnessSq) + alphaRoughnessSq);

    let GGX = GGXV + GGXL;
    return select(0., 0.5 / GGX, GGX > 0.0);
}

// The following equation(s) model the distribution of microfacet normals across the area being drawn (aka D())
// Implementation from "Average Irregularity Representation of a Roughened Surface for Ray Reflection" by T. S. Trowbridge, and K. P. Reitz
// Follows the distribution function recommended in the SIGGRAPH 2013 course notes from EPIC Games [1], Equation 3.
fn D_GGX(NdotH: f32, alphaRoughness: f32) -> f32 {
    let alphaRoughnessSq = alphaRoughness * alphaRoughness;
    let f = (NdotH * NdotH) * (alphaRoughnessSq - 1.0) + 1.0;
    return alphaRoughnessSq / (MATH_PI * f * f);
}

// GGX Mask/Shadowing Anisotropic (Same as Babylon.js - smithVisibility_GGXCorrelated_Anisotropic)
// Heitz http://jcgt.org/published/0003/02/03/paper.pdf
fn V_GGX_anisotropic(NdotL: f32, NdotV: f32, BdotV: f32, TdotV: f32, TdotL: f32, BdotL: f32, at: f32, ab: f32) -> f32 {
    let GGXV = NdotL * length(vec3(at * TdotV, ab * BdotV, NdotV));
    let GGXL = NdotV * length(vec3(at * TdotL, ab * BdotL, NdotL));
    let v = 0.5 / (GGXV + GGXL);
    return clamp(v, 0.0, 1.0);
}

// GGX Distribution Anisotropic (Same as Babylon.js)
// https://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf Addenda
fn D_GGX_anisotropic(NdotH: f32, TdotH: f32, BdotH: f32, anisotropy: f32, at: f32, ab: f32) -> f32 {
    let a2 = at * ab;
    let f = vec3(ab * TdotH, at * BdotH, a2 * NdotH);
    let w2 = a2 / dot(f, f);
    return a2 * w2 * w2 / MATH_PI;
}

// Estevez and Kulla http://www.aconty.com/pdf/s2017_pbs_imageworks_sheen.pdf
fn D_Charlie(sheenRoughness: f32, NdotH: f32) -> f32 {
    let s = max(sheenRoughness, 0.000001); //clamp (0,1)
    let alphaG = s * s;
    let invR = 1.0 / alphaG;
    let cos2h = NdotH * NdotH;
    let sin2h = 1.0 - cos2h;
    return (2.0 + invR) * pow(sin2h, invR * 0.5) / (2.0 * MATH_PI);
}

fn lambda_sheen_numeric_helper(x: f32, alphaG: f32) -> f32 {
    let oneMinusAlphaSq = (1.0 - alphaG) * (1.0 - alphaG);
    let a = mix(21.5473, 25.3245, oneMinusAlphaSq);
    let b = mix(3.82987, 3.32435, oneMinusAlphaSq);
    let c = mix(0.19823, 0.16801, oneMinusAlphaSq);
    let d = mix(-1.97760, -1.27393, oneMinusAlphaSq);
    let e = mix(-4.32054, -4.85967, oneMinusAlphaSq);
    return a / (1.0 + b * pow(x, c)) + d * x + e;
}

fn lambda_sheen(cosTheta: f32, alphaG: f32) -> f32 {
    if (abs(cosTheta) < 0.5)
    {
        return exp(lambda_sheen_numeric_helper(cosTheta, alphaG));
    }
    else
    {
        return exp(2.0 * lambda_sheen_numeric_helper(0.5, alphaG) - lambda_sheen_numeric_helper(1.0 - cosTheta, alphaG));
    }
}

fn V_Sheen(NdotL: f32, NdotV: f32, sheenRoughness: f32) -> f32 {
    let s = max(sheenRoughness, 0.000001); //clamp (0,1)
    let alphaG = sheenRoughness * sheenRoughness;

    return clamp(1.0 / ((1.0 + lambda_sheen(NdotV, alphaG) + lambda_sheen(NdotL, alphaG)) *
        (4.0 * NdotV * NdotL)), 0.0, 1.0);
}

fn sheen_LUT(uv: vec2<f32>) -> vec4<f32> {
    let tl = vec4<f32>(1.0,1.0,1.0,1.);
    let tr = vec4<f32>(0.0,0.0,0.0,1.);
    let bl = vec4<f32>(1.0,1.0,1.0,1.);
    let br = vec4<f32>(0.5,0.5,0.5,1.);
    return mix(mix(tr,tr,uv.x),mix(bl,br,uv.x),uv.y);
}

fn albedo_sheen_scaling_LUT(NdotV: f32, sheenRoughnessFactor: f32) -> f32
{
    return sheen_LUT(vec2<f32>(NdotV, sheenRoughnessFactor)).r;
}

// Fresnel equations for dielectric/dielectric interfaces.
// Ref: https://belcour.github.io/blog/research/2017/05/01/brdf-thin-film.html
// Evaluation XYZ sensitivity curves in Fourier space
fn eval_sensitivity(OPD: f32, shift: vec3<f32>) -> vec3<f32> {
    let phase = 2.0 * MATH_PI * OPD * 1.0e-9;
    let val = vec3<f32>(5.4856e-13, 4.4201e-13, 5.2481e-13);
    let pos = vec3<f32>(1.6810e+06, 1.7953e+06, 2.2084e+06);
    let v = vec3<f32>(4.3278e+09, 9.3046e+09, 6.6121e+09);

    let p = phase*phase;
    var xyz = val * sqrt(2.0 * MATH_PI * v) * cos(pos * phase + shift) * exp(-p * v);
    xyz.x += 9.7470e-14 * sqrt(2.0 * MATH_PI * 4.5282e+09) * cos(2.2399e+06 * phase + shift[0]) * exp(-4.5282e+09 * p);
    xyz /= 1.0685e-7;

    let srgb = XYZ_TO_REC709 * xyz;
    return srgb;
}

fn eval_iridescence(outsideIOR: f32, eta2: f32, cosTheta1: f32, thinFilmThickness:f32, baseF0: vec3<f32>) -> vec3<f32> {
    var I = vec3<f32>(1.);

    // Force iridescenceIor -> outsideIOR when thinFilmThickness -> 0.0
    let iridescenceIor = mix(outsideIOR, eta2, smoothstep(0.0, 0.03, thinFilmThickness));
    // Evaluate the cosTheta on the base layer (Snell law)
    let ior = (outsideIOR / iridescenceIor);
    let sinTheta2Sq = ior * ior * (1.0 - (cosTheta1 * cosTheta1));

    // Handle TIR:
    let cosTheta2Sq = 1.0 - sinTheta2Sq;
    if (cosTheta2Sq < 0.0) {
        return I;
    }

    let cosTheta2 = sqrt(cosTheta2Sq);

    // First interface
    let R0 = ior_to_fresnel0_f32(iridescenceIor, outsideIOR);
    let R12 = f_schlick_f32(R0, 1.0, cosTheta1);
    let T121 = 1.0 - R12;
    var phi12 = 0.0;
    if (iridescenceIor < outsideIOR) { phi12 = MATH_PI; }
    let phi21 = MATH_PI - phi12;

    // Second interface
    let baseIOR = fresnel0_to_ior(clamp(baseF0, vec3<f32>(0.0), vec3<f32>(0.9999))); // guard against 1.0
    let R1 = ior_to_fresnel0_vec3(baseIOR, iridescenceIor);
    let R23 = f_schlick_vec3_f32(R1, 1.0, cosTheta2);
    var phi23 = vec3<f32>(0.0);
    if (baseIOR[0] < iridescenceIor) { phi23[0] = MATH_PI; }
    if (baseIOR[1] < iridescenceIor) { phi23[1] = MATH_PI; }
    if (baseIOR[2] < iridescenceIor) { phi23[2] = MATH_PI; }

    // Phase shift
    let OPD = 2.0 * iridescenceIor * thinFilmThickness * cosTheta2;
    let phi = vec3<f32>(phi21) + phi23;

    //// Compound terms
    let R123 = clamp(R12 * R23, vec3<f32>(1e-5), vec3<f32>(0.9999));
    let r123 = sqrt(R123);
    let Rs = (T121 * T121) * R23 / (vec3<f32>(1.0) - R123);

    //// Reflectance term for m = 0 (DC term amplitude)
    I = R12 + Rs;

    // Reflectance term for m > 0 (pairs of diracs)
    var Cm = Rs - T121;
    for (var m = 1; m <= 2; m++)
    {
        Cm *= r123;
        let Sm = 2.0 * eval_sensitivity(f32(m) * OPD, f32(m) * phi);
        I += Cm * Sm;
    }

    // Since out of gamut colors might be produced, negative color values are clamped to 0.
    return max(I, vec3<f32>(0.0));
}

fn BRDF_lambertian_iridescence(f0: vec3<f32>, f90: vec3<f32>, iridescenceFresnel: vec3<f32>, iridescenceFactor: f32, diffuseColor: vec3<f32>, specularWeight: f32, VdotH: f32) -> vec3<f32> {
    // Use the maximum component of the iridescence Fresnel color
    // Maximum is used instead of the RGB value to not get inverse colors for the diffuse BRDF
    let iridescenceFresnelMax = vec3<f32>(max(max(iridescenceFresnel.r, iridescenceFresnel.g), iridescenceFresnel.b));

    let schlickFresnel = f_schlick_vec3_vec3(f0, f90, VdotH);

    // Blend default specular Fresnel with iridescence Fresnel
    let F = mix(schlickFresnel, iridescenceFresnelMax, iridescenceFactor);

    // see https://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    return (1.0 - specularWeight * F) * (diffuseColor / MATH_PI);
}

fn BRDF_specular_GGX_anisotropy(f0: vec3<f32>, f90: vec3<f32>, alphaRoughness: f32, anisotropy: f32, n: vec3<f32>, v: vec3<f32>, l: vec3<f32>, h: vec3<f32>, t: vec3<f32>, b: vec3<f32>) -> vec3<f32> {
    // Roughness along the anisotropy bitangent is the material roughness, while the tangent roughness increases with anisotropy.
    let at = mix(alphaRoughness, 1.0, anisotropy * anisotropy);
    let ab = clamp(alphaRoughness, 0.001, 1.0);

    let NdotL = clamp(dot(n, l), 0.0, 1.0);
    let NdotH = clamp(dot(n, h), 0.001, 1.0);
    let NdotV = dot(n, v);
    let VdotH = clamp(dot(v, h), 0.0, 1.0);

    let V = V_GGX_anisotropic(NdotL, NdotV, dot(b, v), dot(t, v), dot(t, l), dot(b, l), at, ab);
    let D = D_GGX_anisotropic(NdotH, dot(t, h), dot(b, h), anisotropy, at, ab);

    let F = f_schlick_vec3_vec3(f0, f90, VdotH);
    return F * V * D;
}

fn BRDF_specular_GGX_iridescence(f0: vec3<f32>, f90: vec3<f32>, iridescenceFresnel: vec3<f32>, alphaRoughness: f32, iridescenceFactor: f32, specularWeight: f32, VdotH: f32, NdotL: f32, NdotV: f32, NdotH: f32) -> vec3<f32> {
    let F = mix(f_schlick_vec3_vec3(f0, f90, VdotH), iridescenceFresnel, iridescenceFactor);
    let Vis = V_GGX(NdotL, NdotV, alphaRoughness);
    let D = D_GGX(NdotH, alphaRoughness);

    return specularWeight * F * Vis * D;
}

fn BRDF_lambertian(f0: vec3<f32>, f90: vec3<f32>, diffuseColor: vec3<f32>, specularWeight: f32, VdotH: f32) -> vec3<f32> {
    // see https://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    return (1.0 - specularWeight * f_schlick_vec3_vec3(f0, f90, VdotH)) * (diffuseColor / MATH_PI);
}

fn BRDF_specular_GGX(f0: vec3<f32>, f90: vec3<f32>, alphaRoughness: f32, specularWeight: f32, VdotH: f32, NdotL: f32, NdotV: f32, NdotH: f32) -> vec3<f32> {
    let F = f_schlick_vec3_vec3(f0, f90, VdotH);
    let Vis = V_GGX(NdotL, NdotV, alphaRoughness);
    let D = D_GGX(NdotH, alphaRoughness);

    return specularWeight * F * Vis * D;
}

fn BRDF_specular_sheen(sheenColor: vec3<f32>, sheenRoughness: f32, NdotL: f32, NdotV: f32, NdotH: f32) -> vec3<f32> {
    let sheenDistribution = D_Charlie(sheenRoughness, NdotH);
    let sheenVisibility = V_Sheen(NdotL, NdotV, sheenRoughness);
    return sheenColor * sheenDistribution * sheenVisibility;
}

fn get_punctual_radiance_sheen(sheenColor: vec3<f32>, sheenRoughness: f32, NdotL: f32, NdotV: f32, NdotH: f32) -> vec3<f32> {
    return NdotL * BRDF_specular_sheen(sheenColor, sheenRoughness, NdotL, NdotV, NdotH);
}

fn get_punctual_radiance_clearcoat(clearcoatNormal: vec3<f32>, v: vec3<f32>, l: vec3<f32>, h: vec3<f32>, VdotH: f32, f0: vec3<f32>, f90: vec3<f32>, clearcoatRoughness: f32) -> vec3<f32> {
    let NdotL = clamped_dot(clearcoatNormal, l);
    let NdotV = clamped_dot(clearcoatNormal, v);
    let NdotH = clamped_dot(clearcoatNormal, h);
    return NdotL * BRDF_specular_GGX(f0, f90, clearcoatRoughness * clearcoatRoughness, 1.0, VdotH, NdotL, NdotV, NdotH);
}

fn get_punctual_radiance_transmission(normal: vec3<f32>, view: vec3<f32>, pointToLight: vec3<f32>, alphaRoughness: f32, f0: vec3<f32>, f90: vec3<f32>, baseColor: vec3<f32>, ior: f32) -> vec3<f32> {
    let transmissionRougness = apply_ior_to_roughness(alphaRoughness, ior);

    let n = normalize(normal);           // Outward direction of surface point
    let v = normalize(view);             // Direction from surface point to view
    let l = normalize(pointToLight);
    let l_mirror = normalize(l + 2.0*n*dot(-l, n));     // Mirror light reflection vector on surface
    let h = normalize(l_mirror + v);            // Halfway vector between transmission light vector and v

    let D = D_GGX(clamp(dot(n, h), 0.0, 1.0), transmissionRougness);
    let F = f_schlick_vec3_vec3(f0, f90, clamp(dot(v, h), 0.0, 1.0));
    let Vis = V_GGX(clamp(dot(n, l_mirror), 0.0, 1.0), clamp(dot(n, v), 0.0, 1.0), transmissionRougness);

    // Transmission BTDF
    return (1.0 - F) * baseColor * D * Vis;
}

fn get_range_attenuation(range: f32, distance: f32) -> f32 {
    if (range <= 0.0)
    {
        // negative range means unlimited
        return 1.0 / pow(distance, 2.0);
    }
    return max(min(1.0 - pow(distance / range, 4.0), 1.0), 0.0) / pow(distance, 2.0);
}

fn get_spot_attenuation(pointToLight: vec3<f32>, spotDirection: vec3<f32>, outerConeCos: f32, innerConeCos: f32) -> f32 {
    let actualCos = dot(normalize(spotDirection), normalize(-pointToLight));
    if (actualCos > outerConeCos)
    {
        if (actualCos < innerConeCos)
        {
            let angularAttenuation = (actualCos - outerConeCos) / (innerConeCos - outerConeCos);
            return angularAttenuation * angularAttenuation;
        }
        return 1.0;
    }
    return 0.0;
}

fn get_light_intensity(light: ptr<function, LightData>, pointToLight: vec3<f32>) -> vec3<f32> {
    var rangeAttenuation = 1.0;
    var spotAttenuation = 1.0;

    if ((*light).light_type != LIGHT_TYPE_DIRECTIONAL)
    {
        rangeAttenuation = get_range_attenuation((*light).range, length(pointToLight));
    }
    if ((*light).light_type == LIGHT_TYPE_SPOT)
    {
        spotAttenuation = get_spot_attenuation(pointToLight, (*light).direction, (*light).outer_cone_angle, (*light).inner_cone_angle);
    }
    return rangeAttenuation * spotAttenuation * (*light).intensity * (*light).color;
}

fn get_volume_transmission_ray(n: vec3<f32>, v: vec3<f32>, thickness: f32, ior: f32, scale: f32) -> vec3<f32> {
    // Direction of refracted light.
    let refractionVector = refract(-v, normalize(n), 1.0 / ior);
    // The thickness is specified in local space.
    return normalize(refractionVector) * thickness * scale;
}

// Compute attenuated light as it travels through a volume.
fn apply_volume_attenuation(radiance: vec3<f32>, transmissionDistance: f32, attenuationColor: vec3<f32>, attenuationDistance: f32) -> vec3<f32> {
    if (attenuationDistance == 0.0)
    {
        // Attenuation distance is +∞ (which we indicate by zero), i.e. the transmitted color is not attenuated at all.
        return radiance;
    }
    else
    {
        // Compute light attenuation using Beer's law.
        let attenuationCoefficient = -log(attenuationColor) / attenuationDistance;
        let transmittance = exp(-attenuationCoefficient * transmissionDistance); // Beer's law
        return transmittance * radiance;
    }
}

fn get_IBL_radiance_GGX(n: vec3<f32>, v: vec3<f32>, roughness: f32, F0: vec3<f32>, specularWeight: f32) -> vec3<f32> {
	let NdotV = clamped_dot(n, v);
	let reflection = normalize(reflect(-v, n));
    
	let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, roughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
	let f_ab = sample_texture(brdfSamplePoint).rg;
    
    let specular_env_uv = vec3<f32>(compute_equirectangular_uv(reflection), f32(constant_data.environment_map_texture_index));	
	let specularLight = sample_texture(specular_env_uv).rgb;

    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera
	let Fr = max(vec3<f32>(1. - roughness), F0) - F0;
	let k_S = F0 + Fr * pow(1. - NdotV, 5.);
	let FssEss = k_S * f_ab.x + f_ab.y;

	return specularWeight * specularLight * FssEss;
} 


fn get_IBL_radiance_GGX_iridescence(n: vec3<f32>, v: vec3<f32>, roughness: f32, F0: vec3<f32>, iridescenceFresnel: vec3<f32>, iridescenceFactor: f32, specularWeight: f32) -> vec3<f32> {
	let NdotV = clamped_dot(n, v);
	let reflection = normalize(reflect(-v, n));

	let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, roughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
	let f_ab = sample_texture(brdfSamplePoint).rg;
    
    let specular_env_uv = vec3<f32>(compute_equirectangular_uv(reflection), f32(constant_data.environment_map_texture_index));	
	let specularLight = sample_texture(specular_env_uv).rgb;
    
    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera
	let Fr = max(vec3<f32>(1. - roughness), F0) - F0;
	let k_S = mix(F0 + Fr * pow(1. - NdotV, 5.), iridescenceFresnel, iridescenceFactor);
	let FssEss = k_S * f_ab.x + f_ab.y;

	return specularWeight * specularLight * FssEss;
} 

fn get_IBL_radiance_lambertian_iridescence(n: vec3<f32>, v: vec3<f32>, roughness: f32, diffuseColor: vec3<f32>, F0: vec3<f32>, iridescenceF0: vec3<f32>, iridescenceFactor: f32, specularWeight: f32) -> vec3<f32> {
	let NdotV = clamped_dot(n, v);
	let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, roughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
	let f_ab = sample_texture(brdfSamplePoint).rg;
    
    let irradiance_uv = vec3<f32>(compute_equirectangular_uv(n), f32(constant_data.environment_map_texture_index));	
	let irradiance = sample_texture(irradiance_uv).rgb;	

    // Use the maximum component of the iridescence Fresnel color
    // Maximum is used instead of the RGB value to not get inverse colors for the diffuse BRDF
	let iridescenceF0Max = vec3<f32>(max(max(iridescenceF0.r, iridescenceF0.g), iridescenceF0.b));

    // Blend between base F0 and iridescence F0
	let mixedF0 = mix(F0, iridescenceF0Max, iridescenceFactor);

    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera

	let Fr = max(vec3<f32>(1. - roughness), mixedF0) - mixedF0;
	let k_S = mixedF0 + Fr * pow(1. - NdotV, 5.);
	let FssEss = specularWeight * k_S * f_ab.x + f_ab.y; // <--- GGX / specular light contribution (scale it down if the specularWeight is low)
	
    // Multiple scattering, from Fdez-Aguera
    let Ems = 1. - (f_ab.x + f_ab.y);
	let F_avg = specularWeight * (mixedF0 + (1. - mixedF0) / 21.);
	let FmsEms = Ems * FssEss * F_avg / (1. - F_avg * Ems);
	let k_D = diffuseColor * (1. - FssEss + FmsEms); // we use +FmsEms as indicated by the formula in the blog post (might be a typo in the implementation)
	
    return (FmsEms + k_D) * irradiance;
} 

fn get_IBL_radiance_anisotropy(n: vec3<f32>, v: vec3<f32>, roughness: f32, anisotropy: f32, anisotropyDirection: vec3<f32>, F0: vec3<f32>, specularWeight: f32) -> vec3<f32> {
	let NdotV = clamped_dot(n, v);

	let tangentRoughness = mix(roughness, 1., anisotropy * anisotropy);
	let anisotropicTangent = cross(anisotropyDirection, v);
	let anisotropicNormal = cross(anisotropicTangent, anisotropyDirection);
	let bendFactor = 1. - anisotropy * (1. - roughness);
	let bendFactorPow4 = bendFactor * bendFactor * bendFactor * bendFactor;
	let bentNormal = normalize(mix(anisotropicNormal, n, bendFactorPow4));
    
	let reflection = normalize(reflect(-v, bentNormal));

    let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, roughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
	let f_ab = sample_texture(brdfSamplePoint).rg;
    
    let specular_env_uv = vec3<f32>(compute_equirectangular_uv(reflection), f32(constant_data.environment_map_texture_index));	
	let specularLight = sample_texture(specular_env_uv).rgb;
    
    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera
	let Fr = max(vec3<f32>(1. - roughness), F0) - F0;
	let k_S = F0 + Fr * pow(1. - NdotV, 5.);
	let FssEss = k_S * f_ab.x + f_ab.y;

	return specularWeight * specularLight * FssEss;
} 

// specularWeight is introduced with KHR_materials_specular
fn get_IBL_radiance_lambertian(n: vec3<f32>, v: vec3<f32>, roughness: f32, diffuseColor: vec3<f32>, F0: vec3<f32>, specularWeight: f32) -> vec3<f32> {
	let NdotV = clamped_dot(n, v);
	let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, roughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
	let f_ab = sample_texture(brdfSamplePoint).rg;
    
    let irradiance_uv = vec3<f32>(compute_equirectangular_uv(n), f32(constant_data.environment_map_texture_index));	
	let irradiance = sample_texture(irradiance_uv).rgb;	

    // see https://bruop.github.io/ibl/#single_scattering_results at Single Scattering Results
    // Roughness dependent fresnel, from Fdez-Aguera

	let Fr = max(vec3<f32>(1. - roughness), F0) - F0;
	let k_S = F0 + Fr * pow(1. - NdotV, 5.);
	let FssEss = specularWeight * k_S * f_ab.x + f_ab.y; // <--- GGX / specular light contribution (scale it down if the specularWeight is low)
	
    // Multiple scattering, from Fdez-Aguera
    let Ems= 1. - (f_ab.x + f_ab.y);
	let F_avg = specularWeight * (F0 + (1. - F0) / 21.);
	let FmsEms = Ems * FssEss * F_avg / (1. - F_avg * Ems);
	let k_D = diffuseColor * (1. - FssEss + FmsEms); // we use +FmsEms as indicated by the formula in the blog post (might be a typo in the implementation)

	return (FmsEms + k_D) * irradiance;
} 

fn get_IBL_radiance_charlie(n: vec3<f32>, v: vec3<f32>, sheenRoughness: f32, sheenColor: vec3<f32>) -> vec3<f32> {
	let NdotV = clamped_dot(n, v);
	let reflection = normalize(reflect(-v, n));
    
	let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, sheenRoughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
	let brdf = sample_texture(brdfSamplePoint).b;
    
    let sheen_env_uv = vec3<f32>(compute_equirectangular_uv(reflection), f32(constant_data.environment_map_texture_index));	
	let sheenLight = sample_texture(sheen_env_uv).rgb;
	return sheenLight * sheenColor * brdf;
} 

fn get_IBL_volume_refraction(n: vec3<f32>, v: vec3<f32>, perceptualRoughness: f32, baseColor: vec3<f32>, f0: vec3<f32>, f90: vec3<f32>, position: vec3<f32>, mesh_scale: f32, ior: f32, thickness: f32, attenuationColor: vec3<f32>, attenuationDistance: f32) -> vec3<f32> {
	let transmissionRay = get_volume_transmission_ray(n, v, thickness, ior, mesh_scale);
	let refractedRayExit = position + transmissionRay;
    
    // Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
	var refractionCoords = world_to_clip(refractedRayExit).xy;
	refractionCoords = refractionCoords + vec2<f32>(1.);
	refractionCoords = refractionCoords / vec2<f32>(2.);
    
    // Sample framebuffer to get pixel the refracted ray hits.
    //let dimensions = vec2<f32>(textureDimensions(radiance_texture));
    let framebufferLod = 0; //log2(dimensions.x) * apply_ior_to_roughness(perceptualRoughness, ior);
	let transmittedLight = vec3<f32>(0.);//textureLoad(radiance_texture, vec2<u32>(dimensions * refractionCoords)).rgb;

    let attenuatedColor = apply_volume_attenuation(transmittedLight, length(transmissionRay), attenuationColor, attenuationDistance);

    // Sample GGX LUT to get the specular component.
    let NdotV: f32 = clamped_dot(n, v);
    let brdfSamplePoint = vec3<f32>(clamp(vec2<f32>(NdotV, perceptualRoughness), vec2<f32>(0., 0.), vec2<f32>(1., 1.)), f32(constant_data.lut_pbr_ggx_texture_index));
    let brdf = sample_texture(brdfSamplePoint).rg;

    let specularColor = f0 * brdf.x + f90 * brdf.y;
    return (1. - specularColor) * attenuatedColor * baseColor;
} 




//Inspired from glTF-Sample-Viewer
fn compute_color_from_material(material_id: u32, pixel_data: ptr<function, PixelData>) -> MaterialInfo {
    var material = materials.data[material_id];

    let v = normalize(view_pos() - (*pixel_data).world_pos);
    var tbn = compute_tbn(&material, pixel_data);

    let NdotV = clamped_dot(tbn.normal,v);
    let TdotV = clamped_dot(tbn.tangent,v);
    let BdotV = clamped_dot(tbn.binormal,v);

    var material_info: MaterialInfo;

    init_material_info_default(&material_info);
    compute_base_color(&material, pixel_data, &material_info);

    if((material.flags & MATERIAL_FLAGS_IOR) != 0u) {
        compute_ior(&material, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_SPECULARGLOSSINESS) != 0u) {
        compute_specular_glossiness(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_METALLICROUGHNESS) != 0u) {
        compute_metallic_roughness(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_SHEEN) != 0u) {
        compute_sheen(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_CLEARCOAT) != 0u) {
        compute_clear_coat(&material, tbn.normal, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_SPECULAR) != 0u) {
        compute_specular(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_TRANSMISSION) != 0u) {
        compute_transmission(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_VOLUME) != 0u) {
        compute_volume(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_IRIDESCENCE) != 0u) {
        compute_iridescence(&material, pixel_data, &material_info);
    }
    if((material.flags & MATERIAL_FLAGS_ANISOTROPY) != 0u) {
        compute_anisotropy(&material, &tbn, &material_info);
    }

    material_info.perceptual_roughness = clamp(material_info.perceptual_roughness, 0.0, 1.0);
    material_info.metallic = clamp(material_info.metallic, 0.0, 1.0);
    
    // Roughness is authored as perceptual roughness; as is convention,
    // convert to material roughness by squaring the perceptual roughness.
    material_info.alpha_roughness = material_info.perceptual_roughness * material_info.perceptual_roughness;

    // Compute reflectance.
    let reflectance = max(max(material_info.f0.r, material_info.f0.g), material_info.f0.b);
    
    // Anything less than 2% is physically impossible and is instead considered to be shadowing. Compare to "Real-Time-Rendering" 4th editon on page 325.
    material_info.f90 = vec3<f32>(1.);

    // LIGHTING
    var f_specular = vec3<f32>(0.0);
    var f_diffuse = vec3<f32>(0.0);
    var f_emissive = vec3<f32>(0.0);
    var f_clearcoat = vec3<f32>(0.0);
    var f_sheen = vec3<f32>(0.0);
    var f_transmission = vec3<f32>(0.0);

    var albedo_sheen_scaling = 1.0;

    var iridescence_fresnel = vec3<f32>(0.);
    var iridescence_f0 = vec3<f32>(0.);
    if((material.flags & MATERIAL_FLAGS_IRIDESCENCE) != 0u) {
        iridescence_fresnel = eval_iridescence(1., material_info.iridescence_ior, NdotV, material_info.iridescence_thickness, material_info.f0);
        iridescence_f0 = schlick_to_f0_vec3(iridescence_fresnel, vec3<f32>(1.), NdotV);
        if(material_info.iridescence_thickness == 0.) { material_info.iridescence_factor = 0.; }
    }

    let specular_weight_and_anisotropy_strength = unpack2x16float(material_info.specular_weight_and_anisotropy_strength);
    let specular_weight = specular_weight_and_anisotropy_strength.x;
    let anisotropy_strength = specular_weight_and_anisotropy_strength.y;

    // TODO - Calculate lighting contribution from image based lighting source (IBL)
    if ((constant_data.flags & CONSTANT_DATA_FLAGS_USE_IBL) != 0) {      
        if((material.flags & MATERIAL_FLAGS_IRIDESCENCE) != 0u) {
            f_specular += get_IBL_radiance_GGX_iridescence(tbn.normal, v, material_info.perceptual_roughness, material_info.f0, iridescence_fresnel, material_info.iridescence_factor, specular_weight);
            f_diffuse += get_IBL_radiance_lambertian_iridescence(tbn.normal, v, material_info.perceptual_roughness, material_info.c_diff, material_info.f0, iridescence_f0, material_info.iridescence_factor, specular_weight);
        }
        else if((material.flags & MATERIAL_FLAGS_ANISOTROPY) != 0u) {
            f_specular += get_IBL_radiance_anisotropy(tbn.normal, v, material_info.perceptual_roughness, anisotropy_strength, material_info.anisotropicB, material_info.f0, specular_weight);
            f_diffuse += get_IBL_radiance_lambertian(tbn.normal, v, material_info.perceptual_roughness, material_info.c_diff, material_info.f0, specular_weight);
        }
        else {
            f_specular += get_IBL_radiance_GGX(tbn.normal, v, material_info.perceptual_roughness, material_info.f0, specular_weight);
            f_diffuse += get_IBL_radiance_lambertian(tbn.normal, v, material_info.perceptual_roughness, material_info.c_diff, material_info.f0, specular_weight);
        }
        if((material.flags & MATERIAL_FLAGS_CLEARCOAT) != 0u) {
            f_clearcoat += get_IBL_radiance_GGX(material_info.clear_coat_normal, v, material_info.clear_coat_roughness_factor, material_info.clear_coat_f0, 1.0);
        }
        if((material.flags & MATERIAL_FLAGS_SHEEN) != 0u) {
            f_sheen += get_IBL_radiance_charlie(tbn.normal, v, material_info.sheen_color_and_roughness_factor.z, material_info.sheen_color_and_roughness_factor.rgb);
        }
        if((material.flags & MATERIAL_FLAGS_TRANSMISSION) != 0u) {
            let mesh = &meshes.data[(*pixel_data).mesh_id];
            let mesh_scale = (*mesh).scale.x;
            f_transmission += get_IBL_volume_refraction(
                tbn.normal, v,
                material_info.perceptual_roughness,
                material_info.c_diff, material_info.f0, material_info.f90,
                (*pixel_data).world_pos, mesh_scale,
                material_info.ior, material_info.thickness_factor, material_info.attenuation_color_and_distance.rgb, material_info.attenuation_color_and_distance.z);
        }
    }
    
    var f_diffuse_ibl = f_diffuse;
    var f_specular_ibl = f_specular;
    var f_sheen_ibl = f_sheen;
    var f_clearcoat_ibl = f_clearcoat;
    f_diffuse = material_info.base_color.rgb;
    f_specular = vec3<f32>(0.0);
    f_sheen = vec3<f32>(0.0);
    f_clearcoat = vec3<f32>(0.0);
   
    let i = hash(constant_data.frame_index) % constant_data.num_lights;
    
    var light = lights.data[i];
    if (light.light_type != LIGHT_TYPE_INVALID) { 
        f_diffuse = vec3<f32>(0.0);
        var pointToLight: vec3<f32>;
        if (light.light_type != LIGHT_TYPE_DIRECTIONAL) { 
            pointToLight = light.position - (*pixel_data).world_pos;
        } else {
            pointToLight = -light.direction;
        }
            
        // BSTF
        var l = normalize(pointToLight);   // Direction from surface point to light
        let h = normalize(l + v);          // Direction of the vector between l and v, called halfway vector
        let NdotL = clamped_dot(tbn.normal, l);
        let NdotH = clamped_dot(tbn.normal, h);
        let NdotV = clamped_dot(tbn.normal, v);
        let LdotH = clamped_dot(l, h);
        let VdotH = clamped_dot(v, h);
        if (NdotL > 0.0 || NdotV > 0.0)
        {
            // Calculation of analytical light
            let intensity = get_light_intensity(&light, pointToLight);
            if((material.flags & MATERIAL_FLAGS_IRIDESCENCE) != 0u) {
                f_diffuse += intensity * NdotL *  BRDF_lambertian_iridescence(material_info.f0, material_info.f90, iridescence_fresnel, material_info.iridescence_factor, material_info.c_diff, specular_weight, VdotH);
                f_specular += intensity * NdotL * BRDF_specular_GGX_iridescence(material_info.f0, material_info.f90, iridescence_fresnel, material_info.alpha_roughness,  material_info.iridescence_factor, specular_weight, VdotH, NdotL, NdotV, NdotH);
            }
            else if((material.flags & MATERIAL_FLAGS_ANISOTROPY) != 0u) {
                f_diffuse += intensity * NdotL *  BRDF_lambertian(material_info.f0, material_info.f90, material_info.c_diff, specular_weight, VdotH);
                f_specular += intensity * NdotL * BRDF_specular_GGX_anisotropy(material_info.f0, material_info.f90, material_info.alpha_roughness, anisotropy_strength, tbn.normal, v, l, h, material_info.anisotropicT, material_info.anisotropicB);
            } else {
                f_diffuse += intensity * NdotL *  BRDF_lambertian(material_info.f0, material_info.f90, material_info.c_diff, specular_weight, VdotH);
                f_specular += intensity * NdotL * BRDF_specular_GGX(material_info.f0, material_info.f90, material_info.alpha_roughness, specular_weight, VdotH, NdotL, NdotV, NdotH);
            }
            
            if((material.flags & MATERIAL_FLAGS_SHEEN) != 0u) {
                f_sheen += intensity * get_punctual_radiance_sheen(material_info.sheen_color_and_roughness_factor.rgb, material_info.sheen_color_and_roughness_factor.w, NdotL, NdotV, NdotH);
                let c = max(max(material_info.sheen_color_and_roughness_factor.r, material_info.sheen_color_and_roughness_factor.g), material_info.sheen_color_and_roughness_factor.b);
                albedo_sheen_scaling = min(1.0 - c * albedo_sheen_scaling_LUT(NdotV, material_info.sheen_color_and_roughness_factor.w),
                    1.0 - c * albedo_sheen_scaling_LUT(NdotL, material_info.sheen_color_and_roughness_factor.w));
            }
            
            if((material.flags & MATERIAL_FLAGS_CLEARCOAT) != 0u) {
                f_clearcoat += intensity * get_punctual_radiance_clearcoat(material_info.clear_coat_normal, v, l, h, VdotH,
                    material_info.clear_coat_f0, material_info.clear_coat_f90, material_info.clear_coat_roughness_factor);
            }
        }
        
        // BDTF
        if((material.flags & MATERIAL_FLAGS_TRANSMISSION) != 0u) {
            // If the light ray travels through the geometry, use the point it exits the geometry again.
            // That will change the angle to the light source, if the material refracts the light ray.
            let mesh = &meshes.data[(*pixel_data).mesh_id];
            let mesh_scale = (*mesh).scale.x;
            let transmission_ray = get_volume_transmission_ray(tbn.normal, v, material_info.thickness_factor, material_info.ior, mesh_scale);
            pointToLight -= transmission_ray;
            l = normalize(pointToLight);
            let intensity = get_light_intensity(&light, pointToLight);
            var transmitted_light = intensity * get_punctual_radiance_transmission(tbn.normal, v, l, material_info.alpha_roughness, material_info.f0, material_info.f90, material_info.c_diff, material_info.ior);
        
            if((material.flags & MATERIAL_FLAGS_VOLUME) != 0u) {
                transmitted_light = apply_volume_attenuation(transmitted_light, length(transmission_ray), material_info.attenuation_color_and_distance.rgb, material_info.attenuation_color_and_distance.w);
            }
            f_transmission += transmitted_light;
        }
    }
    
    f_emissive = material.emissive_color.rgb * material.emissive_strength;
    if (has_texture(&material, TEXTURE_TYPE_EMISSIVE)) {  
      let uv = material_texture_uv(&material, pixel_data, TEXTURE_TYPE_EMISSIVE);
      let texture_color = sample_texture(uv);
      f_emissive *= texture_color.rgb;
    }

    //Layer blending

    var clearcoatFactor = 0.0;
    var clearcoatFresnel = vec3(0.);
    var diffuse = vec3<f32>(0.0);
    var specular = vec3<f32>(0.0);
    var sheen = vec3<f32>(0.0);
    var clearcoat = vec3<f32>(0.0);
   
    var ao = 1.0;
    if (has_texture(&material, TEXTURE_TYPE_OCCLUSION)) {  
        let uv = material_texture_uv(&material, pixel_data, TEXTURE_TYPE_OCCLUSION);
        let texture_color = sample_texture(uv);
        ao = ao * texture_color.r;
        diffuse = f_diffuse + mix(f_diffuse_ibl, f_diffuse_ibl * ao, material.occlusion_strength);
        // apply ambient occlusion to all lighting that is not punctual
        specular = f_specular + mix(f_specular_ibl, f_specular_ibl * ao, material.occlusion_strength);
        sheen = f_sheen + mix(f_sheen_ibl, f_sheen_ibl * ao, material.occlusion_strength);
        clearcoat = f_clearcoat + mix(f_clearcoat_ibl, f_clearcoat_ibl * ao, material.occlusion_strength);
    }
    else {
        diffuse = f_diffuse_ibl + f_diffuse;
        specular = f_specular_ibl + f_specular;
        sheen = f_sheen_ibl + f_sheen;
        clearcoat = f_clearcoat_ibl + f_clearcoat;
    }
    
    if((material.flags & MATERIAL_FLAGS_CLEARCOAT) != 0u) {
        clearcoatFactor = material_info.clear_coat_factor;
        clearcoatFresnel = f_schlick_vec3_vec3(material_info.clear_coat_f0, material_info.clear_coat_f90, clamped_dot(material_info.clear_coat_normal, v));
        clearcoat *= clearcoatFactor;
    }
    
    if((material.flags & MATERIAL_FLAGS_TRANSMISSION) != 0u) {
        diffuse = mix(diffuse, f_transmission, material_info.transmission_factor);
    }

    var color = vec3<f32>(0.);
    if((material.flags & MATERIAL_FLAGS_UNLIT) != 0u) {
        color = material_info.base_color.rgb;
    } else {
        color = f_emissive + diffuse + specular;
        color = sheen + color * albedo_sheen_scaling;
        color = color * (1.0 - clearcoatFactor * clearcoatFresnel) + clearcoat;
    }

    material_info.f_color = vec4<f32>(color, material_info.base_color.a);
    material_info.f_emissive = f_emissive;
    material_info.f_diffuse = f_diffuse;
    material_info.f_diffuse_ibl = f_diffuse_ibl;
    material_info.f_specular = f_specular;
    return material_info;
}
// Need constant_data, meshlets, meshes, indices, runtime_vertices, vertices_attributes

fn visibility_to_gbuffer(visibility_id: u32, hit_point: vec3<f32>) -> PixelData 
{     
    var uv_set: array<vec4<f32>, 4>;
    var normal = vec3<f32>(0.);
    var tangent = vec4<f32>(0.);
    var color = vec4<f32>(1.);

    let meshlet_id = (visibility_id >> 8u) - 1u; 
    let primitive_id = visibility_id & 255u;
    
    let meshlet = &meshlets.data[meshlet_id];
    let index_offset = (*meshlet).indices_offset + (primitive_id * 3u);

    let mesh_id = (*meshlet).mesh_index_and_lod_level >> 3u;
    let mesh = &meshes.data[mesh_id];
    let material_id = u32((*mesh).material_index);
    let position_offset = (*mesh).vertices_position_offset;
    let attributes_offset = (*mesh).vertices_attribute_offset;
    let vertex_layout = (*mesh).flags_and_vertices_attribute_layout & 0x0000FFFFu;
    let orientation = (*mesh).orientation;
    let vertex_attribute_stride = vertex_layout_stride(vertex_layout);   
    let offset_color = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_COLOR);
    let offset_normal = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_NORMAL);
    let offset_tangent = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_TANGENT);
    let offset_uv0 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV1);
    let offset_uv1 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV2);
    let offset_uv2 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV3);
    let offset_uv3 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV4); 

    let vert_indices = vec3<u32>(indices.data[index_offset], indices.data[index_offset + 1u], indices.data[index_offset + 2u]);
    let attr_indices = vec3<u32>(attributes_offset + vert_indices.x * vertex_attribute_stride, 
                                 attributes_offset + vert_indices.y * vertex_attribute_stride,
                                 attributes_offset + vert_indices.z * vertex_attribute_stride);
    
    let p1 = runtime_vertices.data[vert_indices.x + position_offset].world_pos;
    let p2 = runtime_vertices.data[vert_indices.y + position_offset].world_pos;
    let p3 = runtime_vertices.data[vert_indices.z + position_offset].world_pos;
    
    let barycentrics = compute_barycentrics_3d(p1,p2,p3,hit_point); 

    if (offset_color >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_color)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_color)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_color)];
        let c1 = unpack_unorm_to_4_f32(a1);
        let c2 = unpack_unorm_to_4_f32(a2);
        let c3 = unpack_unorm_to_4_f32(a3);
        color *= barycentrics.x * c1 + barycentrics.y * c2 + barycentrics.z * c3;    
    }
    if (offset_normal >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_normal)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_normal)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_normal)];
        let n1 = unpack_snorm_to_3_f32(a1);
        let n2 = unpack_snorm_to_3_f32(a2);
        let n3 = unpack_snorm_to_3_f32(a3);
        normal = barycentrics.x * n1 + barycentrics.y * n2 + barycentrics.z * n3;
        normal = rotate_vector(normal, orientation); 
        normal = normalize(normal);
    }
    if (offset_tangent >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_tangent)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_tangent)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_tangent)];
        let t1 = unpack_snorm_to_4_f32(a1);
        let t2 = unpack_snorm_to_4_f32(a2);
        let t3 = unpack_snorm_to_4_f32(a3);
        let t = barycentrics.x * t1 + barycentrics.y * t2 + barycentrics.z * t3;
        let rot_t = rotate_vector(t.xyz, orientation); 
        tangent = vec4<f32>(rot_t, t.w);
    } else {
        let s = select(-1., 1., normal.z >= 0.);
        let a = -1. / (s + normal.z);
        let b = normal.x * normal.y * a;
        tangent = vec4<f32>(1. + s * normal.x * normal.x * a, s * b, -s * normal.x, 1.);
    }
    if(offset_uv0 >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv0)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv0)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv0)];
        let uv1 = unpack2x16float(a1);
        let uv2 = unpack2x16float(a2);
        let uv3 = unpack2x16float(a3);
        let uv = barycentrics.x * uv1 + barycentrics.y * uv2 + barycentrics.z * uv3;
        var uv_dx = uv2 - uv1;
        var uv_dy = uv3 - uv1; 
        uv_dx = select(uv_dx, vec2<f32>(1., 0.), length(uv_dx) <= 0.01);
        uv_dy = select(uv_dy, vec2<f32>(0., 1.), length(uv_dy) <= 0.01);
        uv_set[0] = vec4<f32>(uv, f32(pack2x16float(uv_dx)), f32(pack2x16float(uv_dy)));
    }
    if(offset_uv1 >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv1)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv1)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv1)];
        let uv1 = unpack2x16float(a1);
        let uv2 = unpack2x16float(a2);
        let uv3 = unpack2x16float(a3);
        let uv = barycentrics.x * uv1 + barycentrics.y * uv2 + barycentrics.z * uv3;
        var uv_dx = uv2 - uv1;
        var uv_dy = uv3 - uv1; 
        uv_dx = select(uv_dx, vec2<f32>(1., 0.), length(uv_dx) <= 0.01);
        uv_dy = select(uv_dy, vec2<f32>(0., 1.), length(uv_dy) <= 0.01);
        uv_set[1] = vec4<f32>(uv, f32(pack2x16float(uv_dx)), f32(pack2x16float(uv_dy)));
    }
    if(offset_uv2 >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv2)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv2)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv2)];
        let uv1 = unpack2x16float(a1);
        let uv2 = unpack2x16float(a2);
        let uv3 = unpack2x16float(a3);
        let uv = barycentrics.x * uv1 + barycentrics.y * uv2 + barycentrics.z * uv3;
        var uv_dx = uv2 - uv1;
        var uv_dy = uv3 - uv1; 
        uv_dx = select(uv_dx, vec2<f32>(1., 0.), length(uv_dx) <= 0.01);
        uv_dy = select(uv_dy, vec2<f32>(0., 1.), length(uv_dy) <= 0.01);
        uv_set[2] = vec4<f32>(uv, f32(pack2x16float(uv_dx)), f32(pack2x16float(uv_dy)));
    }
    if(offset_uv3 >= 0) {
        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv3)];
        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv3)];
        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv3)];
        let uv1 = unpack2x16float(a1);
        let uv2 = unpack2x16float(a2);
        let uv3 = unpack2x16float(a3);
        let uv = barycentrics.x * uv1 + barycentrics.y * uv2 + barycentrics.z * uv3;
        var uv_dx = uv2 - uv1;
        var uv_dy = uv3 - uv1; 
        uv_dx = select(uv_dx, vec2<f32>(1., 0.), length(uv_dx) <= 0.01);
        uv_dy = select(uv_dy, vec2<f32>(0., 1.), length(uv_dy) <= 0.01);
        uv_set[3] = vec4<f32>(uv, f32(pack2x16float(uv_dx)), f32(pack2x16float(uv_dy)));
    }    

    return PixelData(hit_point, material_id, color, normal, mesh_id, tangent, uv_set);
}
const GAMMA: f32 = 2.2;
const INV_GAMMA: f32 = 1.0 / GAMMA;


// ODT_SAT => XYZ => D60_2_D65 => sRGB
const ACESOutputMat: mat3x3<f32> = mat3x3<f32>(
    1.60475, -0.10208, -0.00327,
    -0.53108,  1.10813, -0.07276,
    -0.07367, -0.00605,  1.07602
);

fn Uncharted2ToneMapping(color: vec3<f32>) -> vec3<f32> {
	let A = 0.15;
	let B = 0.50;
	let C = 0.10;
	let D = 0.20;
	let E = 0.02;
	let F = 0.30;
	let W = 11.2;
	let exposure = 2.;
	var result = color * exposure;
	result = ((result * (A * result + C * B) + D * E) / (result * (A * result + B) + D * F)) - E / F;
	let white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	result /= white;
	result = pow(result, vec3<f32>(1. / GAMMA));
	return result;
}

fn tonemap_ACES_Narkowicz(color: vec3<f32>) -> vec3<f32> {
    let A = 2.51;
    let B = 0.03;
    let C = 2.43;
    let D = 0.59;
    let E = 0.14;
    return clamp((color * (A * color + vec3<f32>(B))) / (color * (C * color + vec3<f32>(D)) + vec3<f32>(E)), vec3<f32>(0.0), vec3<f32>(1.0));
}

// ACES filmic tone map approximation
// see https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl
fn RRTAndODTFit(color: vec3<f32>) -> vec3<f32> {
    let a = color * (color + vec3<f32>(0.0245786)) - vec3<f32>(0.000090537);
    let b = color * (0.983729 * color + vec3<f32>(0.4329510)) + vec3<f32>(0.238081);
    return a / b;
}

fn tonemap_ACES_Hill(color: vec3<f32>) -> vec3<f32> {
   var c = ACESOutputMat * RRTAndODTFit(color);
   return clamp(c, vec3<f32>(0.0), vec3<f32>(1.0));
}



// 0-1 linear  from  0-1 sRGB gamma
fn linear_from_gamma_rgb(srgb: vec3<f32>) -> vec3<f32> {
    let cutoff = srgb < vec3<f32>(0.04045);
    let lower = srgb / vec3<f32>(12.92);
    let higher = pow((srgb + vec3<f32>(0.055)) / vec3<f32>(1.055), vec3<f32>(2.4));
    return select(higher, lower, cutoff);
}

// 0-1 sRGB gamma  from  0-1 linear
fn gamma_from_linear_rgb(rgb: vec3<f32>) -> vec3<f32> {
    let cutoff = rgb < vec3<f32>(0.0031308);
    let lower = rgb * vec3<f32>(12.92);
    let higher = vec3<f32>(1.055) * pow(rgb, vec3<f32>(1.0 / 2.4)) - vec3<f32>(0.055);
    return select(higher, lower, cutoff);
}

// 0-1 sRGBA gamma  from  0-1 linear
fn gamma_from_linear_rgba(linear_rgba: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(gamma_from_linear_rgb(linear_rgba.rgb), linear_rgba.a);
}

// [u8; 4] SRGB as u32 -> [r, g, b, a] in 0.-1
fn unpack_color(color: u32) -> vec4<f32> {
    return vec4<f32>(
        f32(color & 255u),
        f32((color >> 8u) & 255u),
        f32((color >> 16u) & 255u),
        f32((color >> 24u) & 255u),
    ) / 255.;
}

// linear to sRGB approximation
// see http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html
fn linearTosRGB(color: vec3<f32>) -> vec3<f32>
{
    return pow(color, vec3(INV_GAMMA));
}

// sRGB to linear approximation
// see http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html
fn sRGBToLinear(srgbIn: vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(pow(srgbIn.xyz, vec3<f32>(GAMMA)));
}


fn draw_triangle_from_visibility(visibility_id: u32, pixel: vec2<u32>, dimensions: vec2<u32>) -> vec3<f32>{
    let meshlet_id = (visibility_id >> 8u) - 1u;
    let primitive_id = visibility_id & 255u;
    let meshlet = &meshlets.data[meshlet_id];
    let index_offset = (*meshlet).indices_offset + (primitive_id * 3u);

    let mesh_id = (*meshlet).mesh_index_and_lod_level >> 3u;
    let mesh = &meshes.data[mesh_id];
    let position_offset = (*mesh).vertices_position_offset;
    
    let vert_indices = vec3<u32>(indices.data[index_offset], indices.data[index_offset + 1u], indices.data[index_offset + 2u]);
    
    let p1 = runtime_vertices.data[vert_indices.x + position_offset].world_pos;
    let p2 = runtime_vertices.data[vert_indices.y + position_offset].world_pos;
    let p3 = runtime_vertices.data[vert_indices.z + position_offset].world_pos;
    
    let line_color = vec3<f32>(0., 1., 1.);
    let line_size = 0.001;
    var color = vec3<f32>(0.);
    color += draw_line_3d(pixel, dimensions, p1, p2, line_color, line_size);
    color += draw_line_3d(pixel, dimensions, p2, p3, line_color, line_size);
    color += draw_line_3d(pixel, dimensions, p3, p1, line_color, line_size);
    return color;
}

fn draw_cube_from_min_max(min: vec3<f32>, max:vec3<f32>, pixel: vec2<u32>, dimensions: vec2<u32>) -> vec3<f32> {  
    let line_color = vec3<f32>(0., 0., 1.);
    let line_size = 0.003;
    var color = vec3<f32>(0.);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(min.x, min.y, min.z), vec3<f32>(max.x, min.y, min.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(max.x, min.y, min.z), vec3<f32>(max.x, min.y, max.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(max.x, min.y, max.z), vec3<f32>(min.x, min.y, max.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(min.x, min.y, max.z), vec3<f32>(min.x, min.y, min.z), line_color, line_size);
    //
    color += draw_line_3d(pixel, dimensions, vec3<f32>(min.x, max.y, min.z), vec3<f32>(max.x, max.y, min.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(max.x, max.y, min.z), vec3<f32>(max.x, max.y, max.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(max.x, max.y, max.z), vec3<f32>(min.x, max.y, max.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(min.x, max.y, max.z), vec3<f32>(min.x, max.y, min.z), line_color, line_size);
    //
    color += draw_line_3d(pixel, dimensions, vec3<f32>(min.x, min.y, min.z), vec3<f32>(min.x, max.y, min.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(min.x, min.y, max.z), vec3<f32>(min.x, max.y, max.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(max.x, min.y, min.z), vec3<f32>(max.x, max.y, min.z), line_color, line_size);
    color += draw_line_3d(pixel, dimensions, vec3<f32>(max.x, min.y, max.z), vec3<f32>(max.x, max.y, max.z), line_color, line_size);
    return color;
}


@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> VertexOutput {
    //only one triangle, exceeding the viewport size
    let uv = vec2<f32>(f32((in_vertex_index << 1u) & 2u), f32(in_vertex_index & 2u));
    let pos = vec4<f32>(uv * vec2<f32>(2., -2.) + vec2<f32>(-1., 1.), 0., 1.);

    var vertex_out: VertexOutput;
    vertex_out.clip_position = pos;
    vertex_out.uv = uv;
    return vertex_out;
}

@fragment
fn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {
    let dimensions = vec2<u32>(u32(constant_data.screen_width), u32(constant_data.screen_height));
    let screen_pixel = vec2<u32>(u32(v_in.uv.x * f32(dimensions.x)), u32(v_in.uv.y * f32(dimensions.y)));

    var out_color = vec4<f32>(0.);
    let pixel = vec2<f32>(screen_pixel);
    
    if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS) != 0) {
        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            let meshlet_id = (visibility_id >> 8u); 
            let meshlet_color = hash(meshlet_id + 1u);
            out_color = vec4<f32>(vec3<f32>(
                f32((meshlet_color << 1u) & 255u),
                f32((meshlet_color >> 3u) & 255u),
                f32((meshlet_color >> 7u) & 255u)
            ) / 255., 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_UV_0) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            out_color = vec4<f32>(vec3<f32>(pixel_data.uv_set[0].xy, 0.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_UV_1) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            out_color = vec4<f32>(vec3<f32>(pixel_data.uv_set[1].xy, 0.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_UV_2) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            out_color = vec4<f32>(vec3<f32>(pixel_data.uv_set[2].xy, 0.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_UV_3) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            out_color = vec4<f32>(vec3<f32>(pixel_data.uv_set[3].xy, 0.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_NORMALS) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            var material = materials.data[pixel_data.material_id];
            let tbn = compute_tbn(&material, &pixel_data);
            out_color = vec4<f32>((vec3<f32>(1.) + tbn.normal) / vec3<f32>(2.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_TANGENT) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            var material = materials.data[pixel_data.material_id];
            let tbn = compute_tbn(&material, &pixel_data);
            out_color = vec4<f32>((vec3<f32>(1.) + tbn.tangent) / vec3<f32>(2.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_BITANGENT) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            var material = materials.data[pixel_data.material_id];
            let tbn = compute_tbn(&material, &pixel_data);
            out_color = vec4<f32>((vec3<f32>(1.) + tbn.binormal) / vec3<f32>(2.), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_BASE_COLOR) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            let material_info = compute_color_from_material(pixel_data.material_id, &pixel_data);
            out_color = vec4<f32>(vec3<f32>(material_info.base_color.rgb), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_METALLIC) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            let material_info = compute_color_from_material(pixel_data.material_id, &pixel_data);
            out_color = vec4<f32>(vec3<f32>(material_info.metallic), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_ROUGHNESS) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let hit_point = pixel_to_world(depth_pixel, depth_dimensions, depth); 

        let visibility_dimensions = textureDimensions(visibility_texture);
        let visibility_scale = vec2<f32>(visibility_dimensions) / vec2<f32>(dimensions);
        let visibility_pixel = vec2<u32>(pixel * visibility_scale);
        let visibility_value = textureLoad(visibility_texture, visibility_pixel, 0);
        let visibility_id = visibility_value.r;
        if (visibility_id != 0u && (visibility_id & 0xFFFFFFFFu) != 0xFF000000u) {
            var pixel_data = visibility_to_gbuffer(visibility_id, hit_point);
            let material_info = compute_color_from_material(pixel_data.material_id, &pixel_data);
            out_color = vec4<f32>(vec3<f32>(material_info.perceptual_roughness), 1.);
        }
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_RADIANCE_BUFFER) != 0) {
        let data_dimensions = vec2<u32>(DEFAULT_WIDTH, DEFAULT_HEIGHT);
        let data_scale = vec2<f32>(data_dimensions) / vec2<f32>(dimensions);
        let data_pixel = vec2<u32>(pixel * data_scale);
        let data_index = (data_pixel.y * data_dimensions.x + data_pixel.x) * SIZE_OF_DATA_BUFFER_ELEMENT;
        let radiance = vec3<f32>(data_buffer_1[data_index], data_buffer_1[data_index + 1u], data_buffer_1[data_index + 2u]);
        out_color = vec4<f32>(radiance, 1.);
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_DEPTH_BUFFER) != 0) {
        let depth_dimensions = textureDimensions(depth_texture);
        let depth_scale = vec2<f32>(depth_dimensions) / vec2<f32>(dimensions);
        let depth_pixel = vec2<u32>(pixel * depth_scale);
        let depth = textureLoad(depth_texture, depth_pixel, 0);
        let v = vec3<f32>(1. - depth) * 10.;
        out_color = vec4<f32>(v, 1.);
    } 
    else if ((constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_PATHTRACE) != 0) {
        var origin = vec3<f32>(0.);
        var direction = vec3<f32>(0.);
        let line_color = vec3<f32>(0., 1., 0.);
        let line_size = 0.003;
        var bounce_index = 0u;
        
        let data_dimensions = vec2<u32>(DEFAULT_WIDTH, DEFAULT_HEIGHT);
        let data_scale = vec2<f32>(data_dimensions) / vec2<f32>(dimensions);
        let data_pixel = vec2<u32>(pixel * data_scale);
        let data_index = (data_pixel.y * data_dimensions.x + data_pixel.x) * SIZE_OF_DATA_BUFFER_ELEMENT;
        let radiance = vec3<f32>(data_buffer_1[data_index], data_buffer_1[data_index + 1u], data_buffer_1[data_index + 2u]);
        var color = radiance.rgb;        
        /*
        var debug_bhv_index = 100u;
        let max_bhv_index = u32(read_value_from_data_buffer(&data_buffer_debug, &debug_bhv_index));
        while(debug_bhv_index < max_bhv_index) 
        {
            var min = read_vec3_from_data_buffer(&data_buffer_debug, &debug_bhv_index);
            var max = read_vec3_from_data_buffer(&data_buffer_debug, &debug_bhv_index);
            color += draw_cube_from_min_max(min, max, screen_pixel, dimensions);
            //color += draw_line_3d(screen_pixel, dimensions, min, max, vec3<f32>(0.,0.,1.), line_size);
        }
        */
        
        var debug_index = 0u;        
        let max_index = u32(data_buffer_debug[debug_index]);
        debug_index = debug_index + 1u;
        if(max_index > 8u) {
            while(debug_index < max_index) {
                let visibility_id = u32(data_buffer_debug[debug_index]);
                color += draw_triangle_from_visibility(visibility_id, screen_pixel, dimensions);
                
                var previous = origin;
                origin = vec3<f32>(data_buffer_debug[debug_index + 1u], data_buffer_debug[debug_index + 2u], data_buffer_debug[debug_index + 3u]);
                direction = vec3<f32>(data_buffer_debug[debug_index + 4u], data_buffer_debug[debug_index + 5u], data_buffer_debug[debug_index + 6u]);
                
                if (bounce_index > 0u) {
                    color += draw_line_3d(screen_pixel, dimensions, previous, origin, line_color, line_size);
                }
                bounce_index += 1u;
                debug_index = debug_index + 7u;
            }
            color += draw_line_3d(screen_pixel, dimensions, origin, origin + direction * 5., line_color, line_size);
            out_color = vec4<f32>(color, 1.);
        }
    }
    
    return select(vec4<f32>(0.), out_color, out_color.a > 0.);
}
      � �          � � (
&
{
  "spirv_code": [],
  "wgsl_code": "const DEFAULT_WIDTH: u32 = 1920u;\nconst DEFAULT_HEIGHT: u32 = 1080u;\nconst SIZE_OF_DATA_BUFFER_ELEMENT: u32 = 4u;\n\nconst CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nconst CONSTANT_DATA_FLAGS_USE_IBL: u32 = 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 1u << 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 1u << 2u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_CONE_AXIS: u32 = 1u << 3u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_RADIANCE_BUFFER: u32 = 1u << 4u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_DEPTH_BUFFER: u32 = 1u << 5u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_PATHTRACE: u32 = 1u << 6u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_NORMALS: u32 = 1u << 7u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_TANGENT: u32 = 1u << 8u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_BITANGENT: u32 = 1u << 9u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_BASE_COLOR: u32 = 1u << 10u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_METALLIC: u32 = 1u << 11u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_ROUGHNESS: u32 = 1u << 12u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_0: u32 = 1u << 13u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_1: u32 = 1u << 14u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_2: u32 = 1u << 15u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_3: u32 = 1u << 16u;\n\nconst MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;\nconst MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nconst TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nconst TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nconst TEXTURE_TYPE_NORMAL: u32 = 2u;\nconst TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nconst TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nconst TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nconst TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nconst TEXTURE_TYPE_SPECULAR: u32 = 7u;\nconst TEXTURE_TYPE_SPECULAR_COLOR: u32 = 8u;\nconst TEXTURE_TYPE_TRANSMISSION: u32 = 9u;\nconst TEXTURE_TYPE_THICKNESS: u32 = 10u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_3: u32 = 11u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_4: u32 = 12u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_5: u32 = 13u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_6: u32 = 14u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_7: u32 = 15u;\nconst TEXTURE_TYPE_COUNT: u32 = 16u;\n\nconst MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nconst MATERIAL_ALPHA_BLEND_MASK = 1u;\nconst MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nconst MESH_FLAGS_NONE: u32 = 0u;\nconst MESH_FLAGS_VISIBLE: u32 = 1u;\nconst MESH_FLAGS_OPAQUE: u32 = 1u << 1u;\nconst MESH_FLAGS_TRANSPARENT: u32 = 1u << 2u;\nconst MESH_FLAGS_WIREFRAME: u32 = 1u << 3u;\nconst MESH_FLAGS_DEBUG: u32 = 1u << 4u;\nconst MESH_FLAGS_UI: u32 = 1u << 5u;\n\n\nconst MATH_PI: f32 = 3.14159265359;\nconst MATH_EPSILON = 0.0000001;\nconst MAX_FLOAT: f32 = 3.402823466e+38;\nconst MAX_TRACING_DISTANCE: f32 = 500.;\nconst HIT_EPSILON: f32 = 0.0001;\nconst INVALID_NODE: i32 = -1;\n\nconst VERTEX_ATTRIBUTE_HAS_POSITION: u32 = 0u;\nconst VERTEX_ATTRIBUTE_HAS_COLOR: u32 = 1u;\nconst VERTEX_ATTRIBUTE_HAS_NORMAL: u32 = 1u << 1u;\nconst VERTEX_ATTRIBUTE_HAS_TANGENT: u32 = 1u << 2u;\nconst VERTEX_ATTRIBUTE_HAS_UV1: u32 = 1u << 3u;\nconst VERTEX_ATTRIBUTE_HAS_UV2: u32 = 1u << 4u;\nconst VERTEX_ATTRIBUTE_HAS_UV3: u32 = 1u << 5u;\nconst VERTEX_ATTRIBUTE_HAS_UV4: u32 = 1u << 6u;\n\nconst MATERIAL_FLAGS_NONE: u32 = 0u;\nconst MATERIAL_FLAGS_UNLIT: u32 = 1u;\nconst MATERIAL_FLAGS_IRIDESCENCE: u32 = 1u << 1u;\nconst MATERIAL_FLAGS_ANISOTROPY: u32 = 1u << 2u;\nconst MATERIAL_FLAGS_CLEARCOAT: u32 = 1u << 3u;\nconst MATERIAL_FLAGS_SHEEN: u32 = 1u << 4u;\nconst MATERIAL_FLAGS_TRANSMISSION: u32 = 1u << 5u;\nconst MATERIAL_FLAGS_VOLUME: u32 = 1u << 6u;\nconst MATERIAL_FLAGS_EMISSIVE_STRENGTH: u32 = 1u << 7u;\nconst MATERIAL_FLAGS_METALLICROUGHNESS: u32 = 1u << 8u;\nconst MATERIAL_FLAGS_SPECULAR: u32 = 1u << 9u;\nconst MATERIAL_FLAGS_SPECULARGLOSSINESS: u32 = 1u << 10u;\nconst MATERIAL_FLAGS_IOR: u32 = 1u << 11u;\nconst MATERIAL_FLAGS_ALPHAMODE_OPAQUE: u32 = 1u << 12u;\nconst MATERIAL_FLAGS_ALPHAMODE_MASK: u32 = 1u << 13u;\nconst MATERIAL_FLAGS_ALPHAMODE_BLEND: u32 = 1u << 14u;\n\nconst LIGHT_TYPE_INVALID: u32 = 0u;\nconst LIGHT_TYPE_DIRECTIONAL: u32 = 1u;\nconst LIGHT_TYPE_POINT: u32 = 1u << 1u;\nconst LIGHT_TYPE_SPOT: u32 = 1u << 2u;\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    inv_view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    view_proj: mat4x4<f32>,\n    inverse_view_proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    frame_index: u32,\n    flags: u32,\n    debug_uv_coords: vec2<f32>,\n    tlas_starting_index: u32,\n    indirect_light_num_bounces: u32,\n    lut_pbr_charlie_texture_index: u32,\n    lut_pbr_ggx_texture_index: u32,\n    environment_map_texture_index: u32,\n    num_lights: u32,\n};\n\nstruct RuntimeVertexData {\n    @location(0) world_pos: vec3<f32>,\n    @location(1) @interpolate(flat) mesh_index: u32,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_vertex: u32,\n    base_instance: u32,\n};\n\nstruct DrawIndexedCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct DispatchCommandSize {\n    x: atomic<u32>,\n    y: atomic<u32>,\n    z: atomic<u32>,\n};\n\nstruct Mesh {\n    vertices_position_offset: u32,\n    vertices_attribute_offset: u32,\n    flags_and_vertices_attribute_layout: u32,\n    material_index: i32,\n    orientation: vec4<f32>,\n    position: vec3<f32>,\n    meshlets_offset: u32,\n    scale: vec3<f32>,\n    blas_index: u32,\n};\n\nstruct Meshlet {\n    @location(5) mesh_index: u32,\n    @location(6) indices_offset: u32,\n    @location(7) indices_count: u32,\n    @location(8) triangles_bhv_index: u32,\n    @location(9) center: vec3<f32>,\n    @location(10) cone_axis_cutoff: u32,\n};\n\nstruct BHVNode {\n    min: vec3<f32>,\n    miss: i32,\n    max: vec3<f32>,\n    reference: i32, //-1 or mesh_index or meshlet_index or triangle_index\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    direction: vec3<f32>,\n    intensity: f32,\n    color: vec3<f32>,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n    _padding1: f32,\n    _padding2: f32,\n};\n\nstruct TextureData {\n    texture_index: i32,\n    layer_index: u32,\n    total_width: u32,\n    total_height: u32,\n    area: vec4<u32>,\n};\n\nstruct Material {\n    roughness_factor: f32,\n    metallic_factor: f32,\n    ior: f32,\n    transmission_factor: f32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    emissive_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n    specular_factors: vec4<f32>,\n    attenuation_color_and_distance: vec4<f32>,\n    thickness_factor: f32,\n    normal_scale_and_alpha_cutoff: u32,\n    occlusion_strength: f32,\n    flags: u32,\n    textures_index_and_coord_set: array<u32, TEXTURE_TYPE_COUNT>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<Material>,\n};\n\nstruct DrawCommands {\n    data: array<DrawCommand>,\n};\n\nstruct DrawIndexedCommands {\n    data: array<DrawIndexedCommand>,\n};\n\nstruct Meshes {\n    data: array<Mesh>,\n};\n\nstruct Meshlets {\n    data: array<Meshlet>,\n};\n\nstruct Indices {\n    data: array<u32>,\n};\n\nstruct RuntimeVertices {\n    data: array<RuntimeVertexData>,\n};\n\nstruct VerticesPositions {\n    data: array<u32>,\n};\n\nstruct VerticesAttributes {\n    data: array<u32>,\n};\n\nstruct BHV {\n    data: array<BHVNode>,\n};\n\n\nstruct Ray {\n    origin: vec3<f32>,\n    t_min: f32,\n    direction: vec3<f32>,\n    t_max: f32,\n};\n\nstruct PixelData {\n    world_pos: vec3<f32>,\n    material_id: u32,\n    color: vec4<f32>,\n    normal: vec3<f32>,\n    mesh_id: u32, \n    tangent: vec4<f32>,\n    uv_set: array<vec4<f32>, 4>,\n};\n\nstruct TBN {\n    normal: vec3<f32>,\n    tangent: vec3<f32>,\n    binormal: vec3<f32>,\n};\n\nstruct MaterialInfo {\n    base_color: vec4<f32>,\n\n    f0: vec3<f32>,\n    ior: f32,\n\n    c_diff: vec3<f32>,\n    perceptual_roughness: f32,\n\n    metallic: f32,\n    specular_weight_and_anisotropy_strength: u32,\n    transmission_factor: f32,\n    thickness_factor: f32,\n\n    attenuation_color_and_distance: vec4<f32>,\n    sheen_color_and_roughness_factor: vec4<f32>,\n\n    clear_coat_f0: vec3<f32>,\n    clear_coat_factor: f32,\n\n    clear_coat_f90: vec3<f32>,\n    clear_coat_roughness_factor: f32,\n\n    clear_coat_normal: vec3<f32>,\n    iridescence_factor: f32,\n\n    anisotropicT: vec3<f32>,\n    iridescence_ior: f32,\n\n    anisotropicB: vec3<f32>,\n    iridescence_thickness: f32,\n\n    alpha_roughness: f32,\n    f90: vec3<f32>,\n    \n    f_color: vec4<f32>,\n    f_emissive: vec3<f32>,\n    f_diffuse: vec3<f32>,\n    f_diffuse_ibl: vec3<f32>,\n    f_specular: vec3<f32>,\n};\nfn quantize_unorm(v: f32, n: u32) -> u32 {\n    let scale = f32((1u << n) - 1u);\n    return u32(0.5 + (v * scale));\n}\nfn quantize_snorm(v: f32, n: u32) -> u32 {\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if v < 0. {\n        return (u32(-v * scale) & c) | (1u << (n - 1u));\n    } else {\n        return u32(v * scale) & c;\n    }\n}\n\nfn decode_unorm(i: u32, n: u32) -> f32 {    \n    let scale = f32((1u << n) - 1u);\n    if (i == 0u) {\n        return 0.;\n    } else if (i == u32(scale)) {\n        return 1.;\n    } else {\n        return (f32(i) - 0.5) / scale;\n    }\n}\n\nfn decode_snorm(i: u32, n: u32) -> f32 {\n    let s = i >> (n - 1u);\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if s > 0u {\n        let r = f32(i & c) / scale;\n        return -r;\n    } else {\n        return f32(i & c) / scale;\n    }\n}\n\nfn pack_3_f32_to_unorm(value: vec3<f32>) -> u32 {\n    let x = quantize_unorm(value.x, 10u) << 20u;\n    let y = quantize_unorm(value.y, 10u) << 10u;\n    let z = quantize_unorm(value.z, 10u);\n    return (x | y | z);\n}\nfn unpack_unorm_to_3_f32(v: u32) -> vec3<f32> {\n    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_unorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_3_f32_to_snorm(value: vec3<f32>) -> u32 {\n    let x = quantize_snorm(value.x, 10u) << 20u;\n    let y = quantize_snorm(value.y, 10u) << 10u;\n    let z = quantize_snorm(value.z, 10u);\n    return (x | y | z);\n}\nfn unpack_snorm_to_3_f32(v: u32) -> vec3<f32> {\n    let vx = decode_snorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_snorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_snorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn unpack_normal(f: f32) -> vec3<f32> {\n\tvar f_var = f;\n\tvar flipZ: f32 = sign(f_var);\n\tf_var = abs(f_var);\n\tlet atanXY: f32 = floor(f_var) / 67.5501 * (3.1415927 * 2.) - 3.1415927;\n\tvar n: vec3<f32> = vec3<f32>(sin(atanXY), cos(atanXY), 0.);\n\tn.z = fract(f_var) * 1869.2296 / 427.67993;\n\tn = normalize(n);\n\tn.z = n.z * (flipZ);\n\treturn n;\n} \n\nfn pack_normal(n: vec3<f32>) -> f32 {\n\tvar n_var = n;\n\tlet flipZ: f32 = sign(n_var.z);\n\tn_var.z = abs(n_var.z);\n\tn_var = n_var / (23.065746);\n\tlet xy: f32 = floor((atan2(n_var.x, n_var.y) + 3.1415927) / (3.1415927 * 2.) * 67.5501);\n\tvar z: f32 = floor(n_var.z * 427.67993) / 1869.2296;\n\tz = z * (1. / max(0.01, length(vec2<f32>(n_var.x, n_var.y))));\n\treturn (xy + z) * flipZ;\n} \n\n\nfn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {\n    let r = quantize_unorm(value.x, 8u) << 24u;\n    let g = quantize_unorm(value.y, 8u) << 16u;\n    let b = quantize_unorm(value.z, 8u) << 8u;\n    let a = quantize_unorm(value.w, 8u);\n    return (r | g | b | a);\n}\nfn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_snorm((v >> 24u) & 255u, 8u);\n    let g = decode_snorm((v >> 16u) & 255u, 8u);\n    let b = decode_snorm((v >> 8u) & 255u, 8u);\n    let a = decode_snorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\nfn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_unorm((v >> 24u) & 255u, 8u);\n    let g = decode_unorm((v >> 16u) & 255u, 8u);\n    let b = decode_unorm((v >> 8u) & 255u, 8u);\n    let a = decode_unorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\n\nfn sign_not_zero(v: vec2<f32>) -> vec2<f32> {\n\treturn vec2<f32>(select(-1., 1., v.x >= 0.), select(-1., 1., v.y >= 0.));\n} \n\nfn octahedral_mapping(v: vec3<f32>) -> vec2<f32> {\n\tlet l1norm: f32 = abs(v.x) + abs(v.y) + abs(v.z);\n\tvar result: vec2<f32> = v.xy * (1. / l1norm);\n\tif (v.z < 0.) {\n\t\tresult = (1. - abs(result.yx)) * sign_not_zero(result.xy);\n\t}\n\treturn result;\n} \n\nfn octahedral_unmapping(o: vec2<f32>) -> vec3<f32> {\n\tvar v: vec3<f32> = vec3<f32>(o.x, o.y, 1. - abs(o.x) - abs(o.y));\n\tif (v.z < 0.) {\n\t\tvar vxy = v.xy;\n        vxy = (1. - abs(v.yx)) * sign_not_zero(v.xy);\n        v.x = vxy.x;\n        v.y = vxy.y;\n\t}\n\treturn normalize(v);\n} \n\nfn f32tof16(v: f32) -> u32 {\n    return pack2x16float(vec2<f32>(v, 0.));\n}\n\nfn f16tof32(v: u32) -> f32 {\n    return unpack2x16float(v & 0x0000FFFFu).x;\n}\n\nfn pack_into_R11G11B10F(rgb: vec3<f32>) -> u32 {\n\tlet r = (f32tof16(rgb.r) << 17u) & 0xFFE00000u;\n\tlet g = (f32tof16(rgb.g) << 6u) & 0x001FFC00u;\n\tlet b = (f32tof16(rgb.b) >> 5u) & 0x000003FFu;\n\treturn r | g | b;\n} \n\nfn unpack_from_R11G11B10F(rgb: u32) -> vec3<f32> {\n\tlet r = f16tof32((rgb >> 17u) & 0x7FF0u);\n\tlet g = f16tof32((rgb >> 6u) & 0x7FF0u);\n\tlet b = f16tof32((rgb << 5u) & 0x7FE0u);\n\treturn vec3<f32>(r, g, b);\n} \n\n\nfn iq_hash(v: vec2<f32>) -> f32 {\n    return fract(sin(dot(v, vec2(11.9898, 78.233))) * 43758.5453);\n}\nfn blue_noise(in: vec2<f32>) -> f32 {\n    var v =  iq_hash( in + vec2<f32>(-1., 0.) )\n             + iq_hash( in + vec2<f32>( 1., 0.) )\n             + iq_hash( in + vec2<f32>( 0., 1.) )\n             + iq_hash( in + vec2<f32>( 0.,-1.) ); \n    v /= 4.;\n    return (iq_hash(in) - v + .5);\n}\n\n// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.\nfn hash( x: u32 ) -> u32 {\n    var v = x;\n    v += ( v << 10u );\n    v ^= ( v >>  6u );\n    v += ( v <<  3u );\n    v ^= ( v >> 11u );\n    v += ( v << 15u );\n    return v;\n}\n\nfn hash1(seed: f32) -> f32 {\n    var p = fract(seed * .1031);\n    p *= p + 33.33;\n    p *= p + p;\n    return fract(p);\n}\n\nfn hash2(seed: ptr<function, f32>) -> vec2<f32> {\n    let a = (*seed) + 0.1;\n    let b = a + 0.1;\n    (*seed) = b;\n    return fract(sin(vec2(a,b))*vec2(43758.5453123,22578.1459123));\n}\n\nfn hash3(seed: ptr<function, f32>) -> vec3<f32> {\n    let a = (*seed) + 0.1;\n    let b = a + 0.1;\n    let c = b + 0.1;\n    (*seed) = c;\n    return fract(sin(vec3(a,b,c))*vec3(43758.5453123,22578.1459123,19642.3490423));\n}\n\n// This is PCG2d\nfn get_random_numbers(seed: ptr<function, vec2<u32>>) -> vec2<f32> {\n    var v = (*seed) * 1664525u + 1013904223u;\n    v.x += v.y * 1664525u; v.y += v.x * 1664525u;\n    v ^= v >> vec2u(16u);\n    v.x += v.y * 1664525u; v.y += v.x * 1664525u;\n    v ^= v >> vec2u(16u);\n    *seed = v;\n    return vec2<f32>(v) * 2.32830643654e-10;\n}\n\nfn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) \n{\n    let c = *ptr_a;\n    *ptr_a = *ptr_b;\n    *ptr_b = c;\n}\n\nfn mod_f32(v: f32, m: f32) -> f32\n{\n    return v - (m * floor(v/m));\n}\n\nfn clamped_dot(a: vec3<f32>, b: vec3<f32>) -> f32 {\n    return clamp(dot(a,b), 0., 1.);\n}\n\nfn has_vertex_attribute(vertex_attribute_layout: u32, attribute_to_check: u32) -> bool {\n    return bool(vertex_attribute_layout & attribute_to_check);\n}\nfn vertex_attribute_offset(vertex_attribute_layout: u32, attribute_to_check: u32) -> i32 \n{\n    if(has_vertex_attribute(vertex_attribute_layout, attribute_to_check)) {\n        let mask = (vertex_attribute_layout & 0x0000FFFFu) & (~attribute_to_check & (attribute_to_check - 1u));\n        return i32(countOneBits(mask));\n    }\n    return -1;\n}\nfn vertex_layout_stride(vertex_attribute_layout: u32) -> u32 \n{\n    return countOneBits((vertex_attribute_layout & 0x0000FFFFu));\n}\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) id: u32,\n};\n\nstruct FragmentOutput {\n    @location(0) output: u32,\n};\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n\n@vertex\nfn vs_main(\n    @builtin(instance_index) meshlet_id: u32,\n    v_in: RuntimeVertexData,\n) -> VertexOutput {\n    var vertex_out: VertexOutput;\n    vertex_out.clip_position = constant_data.view_proj * vec4<f32>(v_in.world_pos, 1.);\n    vertex_out.id = meshlet_id + 1u;    \n\n    return vertex_out;\n}\n\n@fragment\nfn fs_main(\n    @builtin(primitive_index) primitive_index: u32,\n    v_in: VertexOutput,\n) -> FragmentOutput {    \n    var fragment_out: FragmentOutput;\n    let visibility_id = (v_in.id << 8u) | primitive_index;   \n    fragment_out.output = visibility_id;    \n    return fragment_out;\n}\n"
}
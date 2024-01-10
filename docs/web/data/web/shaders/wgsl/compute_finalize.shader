{
  "spirv_code": [],
  "wgsl_code": "const MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;\nconst MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nconst TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nconst TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nconst TEXTURE_TYPE_NORMAL: u32 = 2u;\nconst TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nconst TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nconst TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nconst TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nconst TEXTURE_TYPE_SPECULAR: u32 = 7u;\nconst TEXTURE_TYPE_SPECULAR_COLOR: u32 = 8u;\nconst TEXTURE_TYPE_TRANSMISSION: u32 = 9u;\nconst TEXTURE_TYPE_THICKNESS: u32 = 10u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_3: u32 = 11u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_4: u32 = 12u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_5: u32 = 13u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_6: u32 = 14u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING_7: u32 = 15u;\nconst TEXTURE_TYPE_COUNT: u32 = 16u;\n\nconst MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nconst MATERIAL_ALPHA_BLEND_MASK = 1u;\nconst MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nconst MESH_FLAGS_NONE: u32 = 0u;\nconst MESH_FLAGS_VISIBLE: u32 = 1u;\nconst MESH_FLAGS_OPAQUE: u32 = 1u << 1u;\nconst MESH_FLAGS_TRANSPARENT: u32 = 1u << 2u;\nconst MESH_FLAGS_WIREFRAME: u32 = 1u << 3u;\nconst MESH_FLAGS_DEBUG: u32 = 1u << 4u;\nconst MESH_FLAGS_UI: u32 = 1u << 5u;\n\nconst CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nconst CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 1u << 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 1u << 2u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_CONE_AXIS: u32 = 1u << 3u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_RADIANCE_BUFFER: u32 = 1u << 4u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_DEPTH_BUFFER: u32 = 1u << 5u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_PATHTRACE: u32 = 1u << 6u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_NORMALS: u32 = 1u << 7u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_TANGENT: u32 = 1u << 8u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_BITANGENT: u32 = 1u << 9u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_BASE_COLOR: u32 = 1u << 10u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_METALLIC: u32 = 1u << 11u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_ROUGHNESS: u32 = 1u << 12u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_0: u32 = 1u << 13u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_1: u32 = 1u << 14u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_2: u32 = 1u << 15u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_UV_3: u32 = 1u << 16u;\nconst CONSTANT_DATA_FLAGS_USE_IBL: u32 = 1u << 17u;\n\n\nconst MATH_PI: f32 = 3.14159265359;\nconst MATH_EPSILON = 0.0000001;\nconst MAX_FLOAT: f32 = 3.402823466e+38;\nconst MAX_TRACING_DISTANCE: f32 = 500.;\nconst HIT_EPSILON: f32 = 0.0001;\nconst INVALID_NODE: i32 = -1;\n\nconst VERTEX_ATTRIBUTE_HAS_POSITION: u32 = 0u;\nconst VERTEX_ATTRIBUTE_HAS_COLOR: u32 = 1u;\nconst VERTEX_ATTRIBUTE_HAS_NORMAL: u32 = 1u << 1u;\nconst VERTEX_ATTRIBUTE_HAS_TANGENT: u32 = 1u << 2u;\nconst VERTEX_ATTRIBUTE_HAS_UV1: u32 = 1u << 3u;\nconst VERTEX_ATTRIBUTE_HAS_UV2: u32 = 1u << 4u;\nconst VERTEX_ATTRIBUTE_HAS_UV3: u32 = 1u << 5u;\nconst VERTEX_ATTRIBUTE_HAS_UV4: u32 = 1u << 6u;\n\nconst MATERIAL_FLAGS_NONE: u32 = 0u;\nconst MATERIAL_FLAGS_UNLIT: u32 = 1u;\nconst MATERIAL_FLAGS_IRIDESCENCE: u32 = 1u << 1u;\nconst MATERIAL_FLAGS_ANISOTROPY: u32 = 1u << 2u;\nconst MATERIAL_FLAGS_CLEARCOAT: u32 = 1u << 3u;\nconst MATERIAL_FLAGS_SHEEN: u32 = 1u << 4u;\nconst MATERIAL_FLAGS_TRANSMISSION: u32 = 1u << 5u;\nconst MATERIAL_FLAGS_VOLUME: u32 = 1u << 6u;\nconst MATERIAL_FLAGS_EMISSIVE_STRENGTH: u32 = 1u << 7u;\nconst MATERIAL_FLAGS_METALLICROUGHNESS: u32 = 1u << 8u;\nconst MATERIAL_FLAGS_SPECULAR: u32 = 1u << 9u;\nconst MATERIAL_FLAGS_SPECULARGLOSSINESS: u32 = 1u << 10u;\nconst MATERIAL_FLAGS_IOR: u32 = 1u << 11u;\nconst MATERIAL_FLAGS_ALPHAMODE_OPAQUE: u32 = 1u << 12u;\nconst MATERIAL_FLAGS_ALPHAMODE_MASK: u32 = 1u << 13u;\nconst MATERIAL_FLAGS_ALPHAMODE_BLEND: u32 = 1u << 14u;\n\nconst LIGHT_TYPE_INVALID: u32 = 0u;\nconst LIGHT_TYPE_DIRECTIONAL: u32 = 1u;\nconst LIGHT_TYPE_POINT: u32 = 1u << 1u;\nconst LIGHT_TYPE_SPOT: u32 = 1u << 2u;\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    inverse_view_proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    frame_index: u32,\n    flags: u32,\n    debug_uv_coords: vec2<f32>,\n    tlas_starting_index: u32,\n    indirect_light_num_bounces: u32\n};\n\nstruct RuntimeVertexData {\n    @location(0) world_pos: vec3<f32>,\n    @location(1) @interpolate(flat) mesh_index: u32,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_vertex: u32,\n    base_instance: u32,\n};\n\nstruct DrawIndexedCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct DispatchCommandSize {\n    x: atomic<u32>,\n    y: atomic<u32>,\n    z: atomic<u32>,\n};\n\nstruct Mesh {\n    vertices_position_offset: u32,\n    vertices_attribute_offset: u32,\n    flags_and_vertices_attribute_layout: u32,\n    material_index: i32,\n    orientation: vec4<f32>,\n    position: vec3<f32>,\n    meshlets_offset: u32,\n    scale: vec3<f32>,\n    blas_index: u32,\n};\n\nstruct Meshlet {\n    @location(5) mesh_index: u32,\n    @location(6) indices_offset: u32,\n    @location(7) indices_count: u32,\n    @location(8) triangles_bhv_index: u32,\n    @location(9) center: vec3<f32>,\n    @location(10) cone_axis_cutoff: u32,\n};\n\nstruct BHVNode {\n    min: vec3<f32>,\n    miss: i32,\n    max: vec3<f32>,\n    reference: i32, //-1 or mesh_index or meshlet_index or triangle_index\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    direction: vec3<f32>,\n    intensity: f32,\n    color: vec3<f32>,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n    _padding1: f32,\n    _padding2: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: u32,\n    total_height: u32,\n    area: vec4<u32>,\n};\n\nstruct Material {\n    roughness_factor: f32,\n    metallic_factor: f32,\n    ior: f32,\n    transmission_factor: f32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    emissive_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n    specular_factors: vec4<f32>,\n    attenuation_color_and_distance: vec4<f32>,\n    thickness_factor: f32,\n    alpha_cutoff: f32,\n    occlusion_strength: f32,\n    flags: u32,\n    textures_index_and_coord_set: array<u32, TEXTURE_TYPE_COUNT>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<Material>,\n};\n\nstruct DrawCommands {\n    data: array<DrawCommand>,\n};\n\nstruct DrawIndexedCommands {\n    data: array<DrawIndexedCommand>,\n};\n\nstruct Meshes {\n    data: array<Mesh>,\n};\n\nstruct Meshlets {\n    data: array<Meshlet>,\n};\n\nstruct Indices {\n    data: array<u32>,\n};\n\nstruct RuntimeVertices {\n    data: array<RuntimeVertexData>,\n};\n\nstruct VerticesPositions {\n    data: array<u32>,\n};\n\nstruct VerticesAttributes {\n    data: array<u32>,\n};\n\nstruct BHV {\n    data: array<BHVNode>,\n};\n\n\nstruct Ray {\n    origin: vec3<f32>,\n    t_min: f32,\n    direction: vec3<f32>,\n    t_max: f32,\n};\n\nstruct RadianceData {\n    origin: vec3<f32>,\n    seed_x: u32,\n    direction: vec3<f32>,\n    seed_y: u32,\n    radiance: vec3<f32>,\n    pixel: u32,\n    throughput_weight: vec3<f32>,\n    bounce: u32,\n};\n\nstruct RadianceDataBuffer {\n    data: array<RadianceData>,\n};\n\nstruct PixelData {\n    world_pos: vec3<f32>,\n    material_id: u32,\n    color: vec4<f32>,\n    normal: vec3<f32>,\n    mesh_scale: f32, \n    tangent: vec4<f32>,\n    uv_set: array<vec2<f32>, 4>,\n};\n\nstruct TBN {\n    normal: vec3<f32>,\n    tangent: vec3<f32>,\n    binormal: vec3<f32>,\n}\n\nstruct MaterialInfo {\n    base_color: vec4<f32>,\n\n    f0: vec3<f32>,\n    ior: f32,\n\n    c_diff: vec3<f32>,\n    perceptual_roughness: f32,\n\n    metallic: f32,\n    specular_weight_and_anisotropy_strength: u32,\n    transmission_factor: f32,\n    thickness_factor: f32,\n\n    attenuation_color_and_distance: vec4<f32>,\n    sheen_color_and_roughness_factor: vec4<f32>,\n\n    clear_coat_f0: vec3<f32>,\n    clear_coat_factor: f32,\n\n    clear_coat_f90: vec3<f32>,\n    clear_coat_roughness_factor: f32,\n\n    clear_coat_normal: vec3<f32>,\n    iridescence_factor: f32,\n\n    anisotropicT: vec3<f32>,\n    iridescence_ior: f32,\n\n    anisotropicB: vec3<f32>,\n    iridescence_thickness: f32,\n\n    alpha_roughness: f32,\n    f90: vec3<f32>,\n    \n    f_color: vec4<f32>,\n    f_emissive: vec3<f32>,\n    f_diffuse: vec3<f32>,\n    f_diffuse_ibl: vec3<f32>,\n    f_specular: vec3<f32>,\n}\nfn quantize_unorm(v: f32, n: u32) -> u32 {\n    let scale = f32((1u << n) - 1u);\n    return u32(0.5 + (v * scale));\n}\nfn quantize_snorm(v: f32, n: u32) -> u32 {\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if v < 0. {\n        return (u32(-v * scale) & c) | (1u << (n - 1u));\n    } else {\n        return u32(v * scale) & c;\n    }\n}\n\nfn decode_unorm(i: u32, n: u32) -> f32 {    \n    let scale = f32((1u << n) - 1u);\n    if (i == 0u) {\n        return 0.;\n    } else if (i == u32(scale)) {\n        return 1.;\n    } else {\n        return (f32(i) - 0.5) / scale;\n    }\n}\n\nfn decode_snorm(i: u32, n: u32) -> f32 {\n    let s = i >> (n - 1u);\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if s > 0u {\n        let r = f32(i & c) / scale;\n        return -r;\n    } else {\n        return f32(i & c) / scale;\n    }\n}\n\nfn pack_3_f32_to_unorm(value: vec3<f32>) -> u32 {\n    let x = quantize_unorm(value.x, 10u) << 20u;\n    let y = quantize_unorm(value.y, 10u) << 10u;\n    let z = quantize_unorm(value.z, 10u);\n    return (x | y | z);\n}\nfn unpack_unorm_to_3_f32(v: u32) -> vec3<f32> {\n    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_unorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_3_f32_to_snorm(value: vec3<f32>) -> u32 {\n    let x = quantize_snorm(value.x, 10u) << 20u;\n    let y = quantize_snorm(value.y, 10u) << 10u;\n    let z = quantize_snorm(value.z, 10u);\n    return (x | y | z);\n}\nfn unpack_snorm_to_3_f32(v: u32) -> vec3<f32> {\n    let vx = decode_snorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_snorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_snorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {\n    let r = quantize_unorm(value.x, 8u) << 24u;\n    let g = quantize_unorm(value.y, 8u) << 16u;\n    let b = quantize_unorm(value.z, 8u) << 8u;\n    let a = quantize_unorm(value.w, 8u);\n    return (r | g | b | a);\n}\nfn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_snorm((v >> 24u) & 255u, 8u);\n    let g = decode_snorm((v >> 16u) & 255u, 8u);\n    let b = decode_snorm((v >> 8u) & 255u, 8u);\n    let a = decode_snorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\nfn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_unorm((v >> 24u) & 255u, 8u);\n    let g = decode_unorm((v >> 16u) & 255u, 8u);\n    let b = decode_unorm((v >> 8u) & 255u, 8u);\n    let a = decode_unorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\n\nfn iq_hash(v: vec2<f32>) -> f32 {\n    return fract(sin(dot(v, vec2(11.9898, 78.233))) * 43758.5453);\n}\nfn blue_noise(in: vec2<f32>) -> f32 {\n    var v =  iq_hash( in + vec2<f32>(-1., 0.) )\n             + iq_hash( in + vec2<f32>( 1., 0.) )\n             + iq_hash( in + vec2<f32>( 0., 1.) )\n             + iq_hash( in + vec2<f32>( 0.,-1.) ); \n    v /= 4.;\n    return (iq_hash(in) - v + .5);\n}\n\n// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.\nfn hash( x: u32 ) -> u32 {\n    var v = x;\n    v += ( v << 10u );\n    v ^= ( v >>  6u );\n    v += ( v <<  3u );\n    v ^= ( v >> 11u );\n    v += ( v << 15u );\n    return v;\n}\n\nfn hash1(seed: f32) -> f32 {\n    var p = fract(seed * .1031);\n    p *= p + 33.33;\n    p *= p + p;\n    return fract(p);\n}\n\nfn hash2(seed: ptr<function, f32>) -> vec2<f32> {\n    let a = (*seed) + 0.1;\n    let b = a + 0.1;\n    (*seed) = b;\n    return fract(sin(vec2(a,b))*vec2(43758.5453123,22578.1459123));\n}\n\nfn hash3(seed: ptr<function, f32>) -> vec3<f32> {\n    let a = (*seed) + 0.1;\n    let b = a + 0.1;\n    let c = b + 0.1;\n    (*seed) = c;\n    return fract(sin(vec3(a,b,c))*vec3(43758.5453123,22578.1459123,19642.3490423));\n}\n\n// This is PCG2d\nfn get_random_numbers(seed: ptr<function, vec2<u32>>) -> vec2<f32> {\n    var v = (*seed) * 1664525u + 1013904223u;\n    v.x += v.y * 1664525u; v.y += v.x * 1664525u;\n    v ^= v >> vec2u(16u);\n    v.x += v.y * 1664525u; v.y += v.x * 1664525u;\n    v ^= v >> vec2u(16u);\n    *seed = v;\n    return vec2<f32>(v) * 2.32830643654e-10;\n}\n\nfn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) \n{\n    let c = *ptr_a;\n    *ptr_a = *ptr_b;\n    *ptr_b = c;\n}\n\nfn mod_f32(v: f32, m: f32) -> f32\n{\n    return v - (m * floor(v/m));\n}\n\nfn clamped_dot(a: vec3<f32>, b: vec3<f32>) -> f32 {\n    return clamp(dot(a,b), 0., 1.);\n}\n\nfn has_vertex_attribute(vertex_attribute_layout: u32, attribute_to_check: u32) -> bool {\n    return bool(vertex_attribute_layout & attribute_to_check);\n}\nfn vertex_attribute_offset(vertex_attribute_layout: u32, attribute_to_check: u32) -> i32 \n{\n    if(has_vertex_attribute(vertex_attribute_layout, attribute_to_check)) {\n        let mask = (vertex_attribute_layout & 0x0000FFFFu) & (~attribute_to_check & (attribute_to_check - 1u));\n        return i32(countOneBits(mask));\n    }\n    return -1;\n}\nfn vertex_layout_stride(vertex_attribute_layout: u32) -> u32 \n{\n    return countOneBits((vertex_attribute_layout & 0x0000FFFFu));\n}\nconst GAMMA: f32 = 2.2;\nconst INV_GAMMA: f32 = 1.0 / GAMMA;\n\n\n// ODT_SAT => XYZ => D60_2_D65 => sRGB\nconst ACESOutputMat: mat3x3<f32> = mat3x3<f32>(\n    1.60475, -0.10208, -0.00327,\n    -0.53108,  1.10813, -0.07276,\n    -0.07367, -0.00605,  1.07602\n);\n\nfn Uncharted2ToneMapping(color: vec3<f32>) -> vec3<f32> {\n\tlet A = 0.15;\n\tlet B = 0.50;\n\tlet C = 0.10;\n\tlet D = 0.20;\n\tlet E = 0.02;\n\tlet F = 0.30;\n\tlet W = 11.2;\n\tlet exposure = 2.;\n\tvar result = color * exposure;\n\tresult = ((result * (A * result + C * B) + D * E) / (result * (A * result + B) + D * F)) - E / F;\n\tlet white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;\n\tresult /= white;\n\tresult = pow(result, vec3<f32>(1. / GAMMA));\n\treturn result;\n}\n\nfn tonemap_ACES_Narkowicz(color: vec3<f32>) -> vec3<f32> {\n    let A = 2.51;\n    let B = 0.03;\n    let C = 2.43;\n    let D = 0.59;\n    let E = 0.14;\n    return clamp((color * (A * color + vec3<f32>(B))) / (color * (C * color + vec3<f32>(D)) + vec3<f32>(E)), vec3<f32>(0.0), vec3<f32>(1.0));\n}\n\n// ACES filmic tone map approximation\n// see https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl\nfn RRTAndODTFit(color: vec3<f32>) -> vec3<f32> {\n    let a = color * (color + vec3<f32>(0.0245786)) - vec3<f32>(0.000090537);\n    let b = color * (0.983729 * color + vec3<f32>(0.4329510)) + vec3<f32>(0.238081);\n    return a / b;\n}\n\nfn tonemap_ACES_Hill(color: vec3<f32>) -> vec3<f32> {\n   var c = ACESOutputMat * RRTAndODTFit(color);\n   return clamp(c, vec3<f32>(0.0), vec3<f32>(1.0));\n}\n\n\n\n// 0-1 linear  from  0-1 sRGB gamma\nfn linear_from_gamma_rgb(srgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = srgb < vec3<f32>(0.04045);\n    let lower = srgb / vec3<f32>(12.92);\n    let higher = pow((srgb + vec3<f32>(0.055)) / vec3<f32>(1.055), vec3<f32>(2.4));\n    return select(higher, lower, cutoff);\n}\n\n// 0-1 sRGB gamma  from  0-1 linear\nfn gamma_from_linear_rgb(rgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = rgb < vec3<f32>(0.0031308);\n    let lower = rgb * vec3<f32>(12.92);\n    let higher = vec3<f32>(1.055) * pow(rgb, vec3<f32>(1.0 / 2.4)) - vec3<f32>(0.055);\n    return select(higher, lower, cutoff);\n}\n\n// 0-1 sRGBA gamma  from  0-1 linear\nfn gamma_from_linear_rgba(linear_rgba: vec4<f32>) -> vec4<f32> {\n    return vec4<f32>(gamma_from_linear_rgb(linear_rgba.rgb), linear_rgba.a);\n}\n\n// [u8; 4] SRGB as u32 -> [r, g, b, a] in 0.-1\nfn unpack_color(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(color & 255u),\n        f32((color >> 8u) & 255u),\n        f32((color >> 16u) & 255u),\n        f32((color >> 24u) & 255u),\n    ) / 255.;\n}\n\n// linear to sRGB approximation\n// see http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html\nfn linearTosRGB(color: vec3<f32>) -> vec3<f32>\n{\n    return pow(color, vec3(INV_GAMMA));\n}\n\n// sRGB to linear approximation\n// see http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html\nfn sRGBToLinear(srgbIn: vec3<f32>) -> vec3<f32>\n{\n    return vec3<f32>(pow(srgbIn.xyz, vec3<f32>(GAMMA)));\n}\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read_write> radiance_data_buffer: RadianceDataBuffer;\n@group(0) @binding(2)\nvar finalize_texture: texture_storage_2d<rgba8unorm, read_write>;\n@group(0) @binding(3)\nvar binding_texture: texture_2d<f32>;\n@group(0) @binding(4)\nvar radiance_texture: texture_storage_2d<rgba8unorm, read_write>;\n\nconst WORKGROUP_SIZE: u32 = 8u;\n\n@compute\n@workgroup_size(WORKGROUP_SIZE, WORKGROUP_SIZE, 1)\nfn main(\n    @builtin(local_invocation_id) local_invocation_id: vec3<u32>, \n    @builtin(workgroup_id) workgroup_id: vec3<u32>,\n    @builtin(global_invocation_id) global_invocation_id: vec3<u32>,\n) {\n    let dimensions = textureDimensions(finalize_texture);\n\n    let pixel = vec2<u32>(global_invocation_id.x, global_invocation_id.y);\n    if (pixel.x >= dimensions.x || pixel.y >= dimensions.y) {\n        return;\n    }     \n            \n    let binding_dimensions = textureDimensions(binding_texture);\n    let binding_scale = vec2<f32>(binding_dimensions) / vec2<f32>(dimensions);\n    let binding_pixel = vec2<u32>((vec2<f32>(0.5) + vec2<f32>(pixel)) * binding_scale);\n    let binding_value = textureLoad(binding_texture, binding_pixel, 0);\n    var index = pack4x8unorm(binding_value);\n    \n    var radiance = vec4<f32>(0.,0.,0.,1.);\n    if(index != 0u) {\n        index -= 1u;\n        radiance = vec4<f32>(radiance_data_buffer.data[index].radiance, 1.);\n    }\n    let radiance_dimensions = textureDimensions(radiance_texture);\n    let radiance_scale = vec2<f32>(radiance_dimensions) / vec2<f32>(dimensions);\n    let radiance_pixel = vec2<u32>((vec2<f32>(0.5) + vec2<f32>(pixel)) * radiance_scale);\n    if(constant_data.frame_index > 0u) {\n        let prev_value = textureLoad(radiance_texture, radiance_pixel);\n        let frame_index = f32(constant_data.frame_index + 1u);\n        let weight = 1. / frame_index;\n        radiance = mix(prev_value, radiance, weight);\n    }\n    textureStore(radiance_texture, radiance_pixel, radiance);     \n     \n    var out_color = vec4<f32>(radiance.rgb, 1.);   \n    //out_color = vec4<f32>(tonemap_ACES_Hill(out_color.rgb), 1.);\n    //out_color = vec4<f32>(linearTosRGB(out_color.rgb), 1.); \n    textureStore(finalize_texture, pixel, out_color);\n}\n"
}
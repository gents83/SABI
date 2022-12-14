{"spirv_code":[],"wgsl_code":"\nfn quantize_unorm(v: f32, n: u32) -> u32 {\n    let scale = f32((1 << n) - 1);\n    return u32(0.5 + (v * scale));\n}\nfn quantize_snorm(v: f32, n: u32) -> u32 {\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if v < 0. {\n        return (u32(-v * scale) & c) | (1u << (n - 1u));\n    } else {\n        return u32(v * scale) & c;\n    }\n}\n\nfn decode_unorm(i: u32, n: u32) -> f32 {    \n    let scale = f32((1 << n) - 1);\n    if (i == 0u) {\n        return 0.;\n    } else if (i == u32(scale)) {\n        return 1.;\n    } else {\n        return (f32(i) - 0.5) / scale;\n    }\n}\n\nfn decode_snorm(i: u32, n: u32) -> f32 {\n    let s = i >> (n - 1u);\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if s > 0u {\n        let r = f32(i & c) / scale;\n        return -r;\n    } else {\n        return f32(i & c) / scale;\n    }\n}\n\n\nfn decode_uv(v: u32) -> vec2<f32> {\n    return unpack2x16float(v);\n}\nfn decode_as_vec3(v: u32) -> vec3<f32> {\n    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_unorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {\n    let r = quantize_unorm(value.x, 8u) << 24u;\n    let g = quantize_unorm(value.y, 8u) << 16u;\n    let b = quantize_unorm(value.z, 8u) << 8u;\n    let a = quantize_unorm(value.w, 8u);\n    return (r | g | b | a);\n}\nfn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_snorm((v >> 24u) & 255u, 8u);\n    let g = decode_snorm((v >> 16u) & 255u, 8u);\n    let b = decode_snorm((v >> 8u) & 255u, 8u);\n    let a = decode_snorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\nfn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_unorm((v >> 24u) & 255u, 8u);\n    let g = decode_unorm((v >> 16u) & 255u, 8u);\n    let b = decode_unorm((v >> 8u) & 255u, 8u);\n    let a = decode_unorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\n\n// 0-1 from 0-255\nfn linear_from_srgb(srgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = srgb < vec3<f32>(10.31475);\n    let lower = srgb / vec3<f32>(3294.6);\n    let higher = pow((srgb + vec3<f32>(14.025)) / vec3<f32>(269.025), vec3<f32>(2.4));\n    return select(higher, lower, cutoff);\n}\n\n// [u8; 4] SRGB as u32 -> [r, g, b, a]\nfn unpack_color(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(color & 255u),\n        f32((color >> 8u) & 255u),\n        f32((color >> 16u) & 255u),\n        f32((color >> 24u) & 255u),\n    );\n}\n\n// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.\nfn hash( x: u32 ) -> u32 {\n    var v = x;\n    v += ( v << 10u );\n    v ^= ( v >>  6u );\n    v += ( v <<  3u );\n    v ^= ( v >> 11u );\n    v += ( v << 15u );\n    return v;\n}\n\n\nfn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) \n{\n    let c = *ptr_a;\n    *ptr_a = *ptr_b;\n    *ptr_b = c;\n}\nlet MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;\nlet MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nlet TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nlet TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nlet TEXTURE_TYPE_NORMAL: u32 = 2u;\nlet TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nlet TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nlet TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nlet TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nlet TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nlet TEXTURE_TYPE_COUNT: u32 = 8u;\n\nlet MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nlet MATERIAL_ALPHA_BLEND_MASK = 1u;\nlet MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nlet MESH_FLAGS_NONE: u32 = 0u;\nlet MESH_FLAGS_VISIBLE: u32 = 1u;\nlet MESH_FLAGS_OPAQUE: u32 = 2u; // 1 << 1\nlet MESH_FLAGS_TRANSPARENT: u32 = 4u;  // 1 << 2\nlet MESH_FLAGS_WIREFRAME: u32 = 8u; // 1 << 3\nlet MESH_FLAGS_DEBUG: u32 = 16u; // 1 << 4\nlet MESH_FLAGS_UI: u32 = 32u; // 1 << 5\n\nlet CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nlet CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_SPHERE: u32 = 4u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 8u;\n\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    inverse_view_proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    cam_fov: f32,\n    flags: u32,\n};\n\nstruct Vertex {\n    @location(0) position_and_color_offset: u32,\n    @location(1) normal_offset: i32,\n    @location(2) tangent_offset: i32,\n    @location(3) mesh_index: u32,\n    @location(4) uvs_offset: vec4<i32>,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_vertex: u32,\n    base_instance: u32,\n};\n\nstruct DrawIndexedCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct Mesh {\n    vertex_offset: u32,\n    indices_offset: u32,\n    material_index: i32,\n    mesh_flags: u32,\n    position: vec3<f32>,\n    meshlets_offset: u32,\n    scale: vec3<f32>,\n    meshlets_count: u32,\n    orientation: vec4<f32>,\n};\n\nstruct Meshlet {\n    @location(5) mesh_index: u32,\n    @location(6) aabb_index: u32,\n    @location(7) indices_offset: u32,\n    @location(8) indices_count: u32,\n    @location(9) center: vec3<f32>,\n    @location(10) cone_axis_cutoff: u32,\n};\n\nstruct AABB {\n    min: vec3<f32>,\n    child_start: i32,\n    max: vec3<f32>,\n    parent_or_count: i32,\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct Material {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<Material>,\n};\n\nstruct DrawCommands {\n    data: array<DrawCommand>,\n};\n\nstruct DrawIndexedCommands {\n    data: array<DrawIndexedCommand>,\n};\n\nstruct Meshes {\n    data: array<Mesh>,\n};\n\nstruct Meshlets {\n    data: array<Meshlet>,\n};\n\nstruct Indices {\n    data: array<u32>,\n};\n\nstruct Vertices {\n    data: array<Vertex>,\n};\n\nstruct Matrices {\n    data: array<mat4x4<f32>>,\n};\n\nstruct Positions {\n    data: array<u32>,\n};\n\nstruct Colors {\n    data: array<u32>,\n};\n\nstruct Normals {\n    data: array<u32>,\n};\n\nstruct Tangents {\n    data: array<vec4<f32>>,\n};\n\nstruct UVs {\n    data: array<u32>,\n};\n\nstruct AABBs {\n    data: array<AABB>,\n};\n\n\nstruct UIPassData {\n    ui_scale: f32,\n}\n\nstruct UIVertex {\n    @builtin(vertex_index) index: u32,\n    @location(0) position: vec2<f32>,\n    @location(1) uv: vec2<f32>,\n    @location(2) color: u32,\n};\n\nstruct UIInstance {\n    @builtin(instance_index) index: u32,\n    @location(3) index_start: u32,\n    @location(4) index_count: u32,\n    @location(5) vertex_start: u32,\n    @location(6) texture_index: u32,\n};\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) color: vec4<f32>,\n    @location(1) tex_coords: vec3<f32>,\n};\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<uniform> ui_pass_data: UIPassData;\n@group(1) @binding(0)\nvar<storage, read> textures: Textures;\n\n@group(2) @binding(0)\nvar default_sampler: sampler;\n\n@group(2) @binding(1)\nvar texture_1: texture_2d_array<f32>;\n@group(2) @binding(2)\nvar texture_2: texture_2d_array<f32>;\n@group(2) @binding(3)\nvar texture_3: texture_2d_array<f32>;\n@group(2) @binding(4)\nvar texture_4: texture_2d_array<f32>;\n@group(2) @binding(5)\nvar texture_5: texture_2d_array<f32>;\n@group(2) @binding(6)\nvar texture_6: texture_2d_array<f32>;\n@group(2) @binding(7)\nvar texture_7: texture_2d_array<f32>;\n\n\nfn sample_texture(tex_coords_and_texture_index: vec3<f32>) -> vec4<f32> {\n    let texture_data_index = i32(tex_coords_and_texture_index.z);\n    var v = vec4<f32>(0.);\n    var tex_coords = vec3<f32>(0.0, 0.0, 0.0);\n    if (texture_data_index < 0) {\n        return v;\n    }\n    let texture = &textures.data[texture_data_index];\n    let atlas_index = (*texture).texture_index;\n    let layer_index = i32((*texture).layer_index);\n\n    tex_coords.x = ((*texture).area.x + tex_coords_and_texture_index.x * (*texture).area.z) / (*texture).total_width;\n    tex_coords.y = ((*texture).area.y + tex_coords_and_texture_index.y * (*texture).area.w) / (*texture).total_height;\n    tex_coords.z = f32(layer_index);\n\n    switch (atlas_index) {\n        case 0u: { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 1u: { v = textureSampleLevel(texture_2, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 2u: { v = textureSampleLevel(texture_3, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 3u: { v = textureSampleLevel(texture_4, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 4u: { v = textureSampleLevel(texture_5, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 5u: { v = textureSampleLevel(texture_6, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 6u: { v = textureSampleLevel(texture_7, default_sampler, tex_coords.xy, layer_index, 0.); }\n        default { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }\n    };\n    return v;\n}\n\n\n@vertex\nfn vs_main(\n    v_in: UIVertex,\n    i_in: UIInstance,\n) -> VertexOutput {\n\n    let ui_scale = ui_pass_data.ui_scale;\n\n    var vertex_out: VertexOutput;\n    vertex_out.clip_position = vec4<f32>(\n        2. * v_in.position.x * ui_scale / constant_data.screen_width - 1.,\n        1. - 2. * v_in.position.y * ui_scale / constant_data.screen_height,\n        0.001 * f32(i_in.index),\n        1.\n    );\n    let color = u32(v_in.color);\n    let c = unpack_color(color);\n    //vertex_out.color = vec4<f32>(linear_from_srgb(c.rgb), c.a / 255.0);\n    vertex_out.color = vec4<f32>(c / 255.);\n    vertex_out.tex_coords = vec3<f32>(v_in.uv.xy, f32(i_in.texture_index));\n\n    return vertex_out;\n}\n\n@fragment\nfn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {\n    let texture_color = sample_texture(v_in.tex_coords);\n    let final_color = vec4<f32>(v_in.color .rgb * texture_color.rgb, v_in.color.a);\n    return final_color;\n}\n"}
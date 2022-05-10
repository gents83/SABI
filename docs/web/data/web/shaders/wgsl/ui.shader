{"spirv_code":[],"wgsl_code":"let MAX_TEXTURE_ATLAS_COUNT: u32 = 16u;\nlet MAX_NUM_LIGHTS: u32 = 64u;\nlet MAX_NUM_TEXTURES: u32 = 512u;\nlet MAX_NUM_MATERIALS: u32 = 512u;\n\nlet TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nlet TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nlet TEXTURE_TYPE_NORMAL: u32 = 2u;\nlet TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nlet TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nlet TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nlet TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nlet TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nlet TEXTURE_TYPE_COUNT: u32 = 8u;\n\nlet CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nlet CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    flags: u32,\n};\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct ShaderMaterialData {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec4<f32>,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\nstruct DynamicData {\n    textures_data: array<TextureData, 512>,//MAX_NUM_TEXTURES>,\n    materials_data: array<ShaderMaterialData, 512>,//MAX_NUM_MATERIALS>,\n    lights_data: array<LightData, 64>,//MAX_NUM_LIGHTS>,\n};\n\nstruct UIData {\n    scale: f32,\n};\n\nstruct VertexInput {\n    //@builtin(vertex_index) index: u32,\n    @location(0) position: vec3<f32>,\n    @location(1) tex_coords_0: vec2<f32>,\n    @location(2) color: u32,\n};\n\nstruct InstanceInput {\n    //@builtin(instance_index) index: u32,\n    @location(3) draw_area: vec4<f32>,\n    @location(4) model_matrix_0: vec4<f32>,\n    @location(5) model_matrix_1: vec4<f32>,\n    @location(6) model_matrix_2: vec4<f32>,\n    @location(7) model_matrix_3: vec4<f32>,\n    @location(8) material_index: i32,\n};\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) color: vec4<f32>,\n    @location(1) @interpolate(flat) material_index: i32,\n    @location(2) tex_coords_base_color: vec3<f32>,\n};\n\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read> dynamic_data: DynamicData;\n@group(0) @binding(2)\nvar<storage, read> ui_data: UIData;\n\n\n@group(1) @binding(0)\nvar default_sampler: sampler;\n@group(1) @binding(1)\nvar depth_sampler: sampler_comparison;\n\n@group(1) @binding(2)\nvar texture_1: texture_2d<f32>;\n@group(1) @binding(3)\nvar texture_2: texture_2d<f32>;\n@group(1) @binding(4)\nvar texture_3: texture_2d<f32>;\n@group(1) @binding(5)\nvar texture_4: texture_2d<f32>;\n@group(1) @binding(6)\nvar texture_5: texture_2d<f32>;\n@group(1) @binding(7)\nvar texture_6: texture_2d<f32>;\n@group(1) @binding(8)\nvar texture_7: texture_2d<f32>;\n@group(1) @binding(9)\nvar texture_8: texture_2d<f32>;\n@group(1) @binding(10)\nvar texture_9: texture_2d<f32>;\n@group(1) @binding(11)\nvar texture_10: texture_2d<f32>;\n@group(1) @binding(12)\nvar texture_11: texture_2d<f32>;\n@group(1) @binding(13)\nvar texture_12: texture_2d<f32>;\n@group(1) @binding(14)\nvar texture_13: texture_2d<f32>;\n@group(1) @binding(15)\nvar texture_14: texture_2d<f32>;\n@group(1) @binding(16)\nvar texture_15: texture_2d<f32>;\n@group(1) @binding(17)\nvar texture_16: texture_2d<f32>;\n\n\nfn get_textures_coord_set(v: VertexInput, material_index: i32, texture_type: u32) -> vec2<f32> {\n    let texture_data_index = dynamic_data.materials_data[material_index].textures_indices[texture_type];\n    return v.tex_coords_0;\n}\n\n\nfn compute_textures_coord(v: VertexInput, material_index: i32, texture_type: u32) -> vec3<f32> {\n    let tex_coords = get_textures_coord_set(v, material_index, texture_type);\n    var t = vec3<f32>(0.0, 0.0, 0.0);\n    let texture_data_index = dynamic_data.materials_data[material_index].textures_indices[texture_type];\n    if (texture_data_index >= 0) {\n        t.x = (dynamic_data.textures_data[texture_data_index].area.x + 0.5 + tex_coords.x * dynamic_data.textures_data[texture_data_index].area.z) / dynamic_data.textures_data[texture_data_index].total_width;\n        t.y = (dynamic_data.textures_data[texture_data_index].area.y + 0.5 + tex_coords.y * dynamic_data.textures_data[texture_data_index].area.w) / dynamic_data.textures_data[texture_data_index].total_height;\n        t.z = f32(dynamic_data.textures_data[texture_data_index].layer_index);\n    }\n    return t;\n}\n\n\n  // linear <-> sRGB conversions\nfn linear_to_srgb(color: vec3<f32>) -> vec3<f32> {\n    if (all(color <= vec3<f32>(0.0031308, 0.0031308, 0.0031308))) {\n        return color * 12.92;\n    }\n    return (pow(abs(color), vec3<f32>(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - vec3<f32>(0.055, 0.055, 0.055);\n}\nfn srgb_to_linear(color: vec3<f32>) -> vec3<f32> {\n    if (all(color <= vec3<f32>(0.04045, 0.04045, 0.04045))) {\n        return color / vec3<f32>(12.92, 12.92, 12.92);\n    }\n    return pow((color + vec3<f32>(0.055, 0.055, 0.055)) / vec3<f32>(1.055, 1.055, 1.055), vec3<f32>(2.4, 2.4, 2.4));\n}\n\nfn linear_from_srgb(srgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = srgb < vec3<f32>(10.31475);\n    let lower = srgb / vec3<f32>(3294.6);\n    let higher = pow((srgb + vec3<f32>(14.025)) / vec3<f32>(269.025), vec3<f32>(2.4));\n    return select(higher, lower, cutoff);\n}\n\nfn rgba_from_integer(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(color & 255u),\n        f32((color >> 8u) & 255u),\n        f32((color >> 16u) & 255u),\n        f32((color >> 24u) & 255u),\n    );\n}\n\n@vertex\nfn vs_main(\n    v: VertexInput,\n    instance: InstanceInput,\n) -> VertexOutput {\n    var vertex_out: VertexOutput;\n    let ui_scale = ui_data.scale;\n    vertex_out.clip_position = vec4<f32>(2. * v.position.x * ui_scale / constant_data.screen_width - 1., 1. - 2. * v.position.y * ui_scale / constant_data.screen_height, v.position.z, 1.);\n    let support_srbg = constant_data.flags & CONSTANT_DATA_FLAGS_SUPPORT_SRGB;\n    let color = rgba_from_integer(v.color);\n    if (support_srbg == 0u) {\n        vertex_out.color = vec4<f32>(color.rgba / 255.);\n    } else {\n        vertex_out.color = vec4<f32>(linear_from_srgb(color.rgb), color.a / 255.);\n    }\n    vertex_out.material_index = instance.material_index;\n\n    if (instance.material_index >= 0) {\n        vertex_out.tex_coords_base_color = compute_textures_coord(v, instance.material_index, TEXTURE_TYPE_BASE_COLOR);\n    }\n\n    return vertex_out;\n}\n\nfn get_atlas_index(material_index: u32, texture_type: u32) -> u32 {\n    let texture_data_index = dynamic_data.materials_data[material_index].textures_indices[texture_type];\n    if (texture_data_index < 0) {\n        return 0u;\n    }\n    return dynamic_data.textures_data[texture_data_index].texture_index;\n}\n\nfn get_texture_color(material_index: u32, texture_type: u32, tex_coords: vec3<f32>) -> vec4<f32> {\n    let atlas_index = get_atlas_index(material_index, texture_type);\n\n    if (atlas_index == 1u) {\n        return textureSampleLevel(texture_2, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 2u) {\n        return textureSampleLevel(texture_3, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 3u) {\n        return textureSampleLevel(texture_4, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 4u) {\n        return textureSampleLevel(texture_5, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 5u) {\n        return textureSampleLevel(texture_6, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 6u) {\n        return textureSampleLevel(texture_7, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 7u) {\n        return textureSampleLevel(texture_8, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 8u) {\n        return textureSampleLevel(texture_9, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 9u) {\n        return textureSampleLevel(texture_10, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 10u) {\n        return textureSampleLevel(texture_11, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 11u) {\n        return textureSampleLevel(texture_12, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 12u) {\n        return textureSampleLevel(texture_13, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 13u) {\n        return textureSampleLevel(texture_14, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 14u) {\n        return textureSampleLevel(texture_15, default_sampler, tex_coords.xy, tex_coords.z);\n    } else if (atlas_index == 15u) {\n        return textureSampleLevel(texture_16, default_sampler, tex_coords.xy, tex_coords.z);\n    }\n    return textureSampleLevel(texture_1, default_sampler, tex_coords.xy, tex_coords.z);\n}\n\n@fragment\nfn fs_main(v: VertexOutput) -> @location(0) vec4<f32> {\n    var color: vec4<f32> = v.color;\n    if (v.material_index >= 0) {\n        color = color * get_texture_color(u32(v.material_index), TEXTURE_TYPE_BASE_COLOR, v.tex_coords_base_color);\n    }\n    return color;\n}\n"}
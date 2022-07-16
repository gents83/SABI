{"spirv_code":[],"wgsl_code":"\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn unpack_unorm_to_4_f32(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(((color >> 24u) / 255u) & 255u),\n        f32(((color >> 16u) / 255u) & 255u),\n        f32(((color >> 8u) / 255u) & 255u),\n        f32((color / 255u) & 255u),\n    );\n}\n\nfn hash(index: u32) -> u32 {\n    var v = index;\n    v = (v + 0x7ed55d16u) + (v << 12u);\n    v = (v ^ 0xc761c23cu) ^ (v >> 19u);\n    v = (v + 0x165667b1u) + (v << 5u);\n    v = (v + 0xd3a2646cu) ^ (v << 9u);\n    v = (v + 0xfd7046c5u) + (v << 3u);\n    v = (v ^ 0xb55a4f09u) ^ (v >> 16u);\n    return v;\n}\n\n// 0-1 from 0-255\nfn linear_from_srgb(srgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = srgb < vec3<f32>(10.31475);\n    let lower = srgb / vec3<f32>(3294.6);\n    let higher = pow((srgb + vec3<f32>(14.025)) / vec3<f32>(269.025), vec3<f32>(2.4));\n    return select(higher, lower, cutoff);\n}\n\n// [u8; 4] SRGB as u32 -> [r, g, b, a]\nfn unpack_color(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(color & 255u),\n        f32((color >> 8u) & 255u),\n        f32((color >> 16u) & 255u),\n        f32((color >> 24u) & 255u),\n    );\n}\n\nfn extract_scale(m: mat4x4<f32>) -> vec3<f32> {\n    let s = mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz);\n    let sx = length(s[0]);\n    let sy = length(s[1]);\n    let det = determinant(s);\n    var sz = length(s[2]);\n    if (det < 0.) {\n        sz = -sz;\n    }\n    return vec3<f32>(sx, sy, sz);\n}\n\nfn matrix_row(m: mat4x4<f32>, row: u32) -> vec4<f32> {\n    if (row == 1u) {\n        return vec4<f32>(m[0].y, m[1].y, m[2].y, m[3].y);\n    } else if (row == 2u) {\n        return vec4<f32>(m[0].z, m[1].z, m[2].z, m[3].z);\n    } else if (row == 3u) {\n        return vec4<f32>(m[0].w, m[1].w, m[2].w, m[3].w);\n    } else {        \n        return vec4<f32>(m[0].x, m[1].x, m[2].x, m[3].x);\n    }\n}\n\nfn normalize_plane(plane: vec4<f32>) -> vec4<f32> {\n    return (plane / length(plane.xyz));\n}\nlet MAX_TEXTURE_ATLAS_COUNT: u32 = 16u;\nlet MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nlet TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nlet TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nlet TEXTURE_TYPE_NORMAL: u32 = 2u;\nlet TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nlet TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nlet TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nlet TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nlet TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nlet TEXTURE_TYPE_COUNT: u32 = 8u;\n\nlet MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nlet MATERIAL_ALPHA_BLEND_MASK = 1u;\nlet MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nlet MESH_FLAGS_NONE: u32 = 0u;\nlet MESH_FLAGS_VISIBLE: u32 = 1u;\nlet MESH_FLAGS_OPAQUE: u32 = 2u; // 1 << 1\nlet MESH_FLAGS_TRANSPARENT: u32 = 4u;  // 1 << 2\nlet MESH_FLAGS_WIREFRAME: u32 = 8u; // 1 << 3\nlet MESH_FLAGS_DEBUG: u32 = 16u; // 1 << 4\nlet MESH_FLAGS_UI: u32 = 32u; // 1 << 5\n\nlet CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nlet CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_SPHERE: u32 = 4u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 8u;\n\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    flags: u32,\n};\n\nstruct DrawVertex {\n    @location(0) position_and_color_offset: u32,\n    @location(1) normal_offset: i32,\n    @location(2) tangent_offset: i32,\n    @location(3) padding_offset: u32,\n    @location(4) uvs_offset: vec4<i32>,\n};\n\nstruct DrawInstance {\n    @location(5) mesh_index: u32,\n    @location(6) matrix_index: u32,\n};\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct DrawMesh {\n    vertex_offset: u32,\n    indices_offset: u32,\n    meshlet_offset: u32,\n    meshlet_count: u32,\n    material_index: i32,\n    matrix_index: i32,\n    mesh_flags: u32,\n};\n\nstruct DrawMeshlet {\n    vertex_offset: u32,\n    vertex_count: u32,\n    indices_offset: u32,\n    indices_count: u32,\n    center_radius: vec4<f32>,\n    cone_axis_cutoff: vec4<f32>,\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct DrawMaterial {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<DrawMaterial>,\n};\n\nstruct Instances {\n    data: array<DrawInstance>,\n};\n\nstruct Commands {\n    data: array<DrawCommand>,\n};\n\nstruct Meshes {\n    data: array<DrawMesh>,\n};\n\nstruct Meshlets {\n    data: array<DrawMeshlet>,\n};\n\nstruct Vertices {\n    data: array<DrawVertex>,\n};\n\nstruct Matrices {\n    data: array<mat4x4<f32>>,\n};\n\nstruct PositionsAndColors {\n    data: array<vec4<f32>>,\n};\n\nstruct NormalsAndPadding {\n    data: array<vec4<f32>>,\n};\n\nstruct Tangents {\n    data: array<vec4<f32>>,\n};\n\nstruct UVs {\n    data: array<vec2<f32>>,\n};\n\n\n\nstruct PbrData {\n    width: u32,\n    height: u32,\n    gbuffer_1: u32,\n    gbuffer_2: u32,\n    gbuffer_3: u32,\n    depth: u32,\n    _padding_2: u32,\n    _padding_3: u32,\n};\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<uniform> pbr_data: PbrData;\n@group(0) @binding(2)\nvar<storage, read> meshes: Meshes;\n@group(0) @binding(3)\nvar<storage, read> materials: Materials;\n@group(0) @binding(4)\nvar<storage, read> textures: Textures;\n@group(0) @binding(5)\nvar<storage, read> lights: Lights;\n\n@group(1) @binding(0)\nvar render_target: texture_storage_2d_array<rgba8unorm, read_write>;\n\n\n\n@group(2) @binding(0)\nvar default_sampler: sampler;\n@group(2) @binding(1)\nvar unfiltered_sampler: sampler;\n@group(2) @binding(2)\nvar depth_sampler: sampler_comparison;\n\n@group(2) @binding(3)\nvar texture_1: texture_2d_array<f32>;\n@group(2) @binding(4)\nvar texture_2: texture_2d_array<f32>;\n@group(2) @binding(5)\nvar texture_3: texture_2d_array<f32>;\n@group(2) @binding(6)\nvar texture_4: texture_2d_array<f32>;\n@group(2) @binding(7)\nvar texture_5: texture_2d_array<f32>;\n@group(2) @binding(8)\nvar texture_6: texture_2d_array<f32>;\n@group(2) @binding(9)\nvar texture_7: texture_2d_array<f32>;\n@group(2) @binding(10)\nvar texture_8: texture_2d_array<f32>;\n@group(2) @binding(11)\nvar texture_9: texture_2d_array<f32>;\n@group(2) @binding(12)\nvar texture_10: texture_2d_array<f32>;\n@group(2) @binding(13)\nvar texture_11: texture_2d_array<f32>;\n@group(2) @binding(14)\nvar texture_12: texture_2d_array<f32>;\n@group(2) @binding(15)\nvar texture_13: texture_2d_array<f32>;\n@group(2) @binding(16)\nvar texture_14: texture_2d_array<f32>;\n@group(2) @binding(17)\nvar texture_15: texture_2d_array<f32>;\n@group(2) @binding(18)\nvar texture_16: texture_2d_array<f32>;\n\n\nfn sample_texture(tex_coords_and_texture_index: vec3<f32>) -> vec4<f32> {\n    let texture_data_index = i32(tex_coords_and_texture_index.z);\n    var tex_coords = vec3<f32>(0.0, 0.0, 0.0);\n    if (texture_data_index < 0) {\n        return vec4<f32>(tex_coords, 0.);\n    }\n    let texture = &textures.data[texture_data_index];\n    let atlas_index = (*texture).texture_index;\n    let layer_index = i32((*texture).layer_index);\n\n    tex_coords.x = ((*texture).area.x + tex_coords_and_texture_index.x * (*texture).area.z) / (*texture).total_width;\n    tex_coords.y = ((*texture).area.y + tex_coords_and_texture_index.y * (*texture).area.w) / (*texture).total_height;\n    tex_coords.z = f32(layer_index);\n\n    switch (atlas_index) {\n        default { return textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 1u: { return textureSampleLevel(texture_2, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 2u: { return textureSampleLevel(texture_3, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 3u: { return textureSampleLevel(texture_4, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 4u: { return textureSampleLevel(texture_5, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 5u: { return textureSampleLevel(texture_6, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 6u: { return textureSampleLevel(texture_7, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 7u: { return textureSampleLevel(texture_8, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 8u: { return textureSampleLevel(texture_9, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 9u: { return textureSampleLevel(texture_10, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 10u: { return textureSampleLevel(texture_11, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 11u: { return textureSampleLevel(texture_12, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 12u: { return textureSampleLevel(texture_13, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 13u: { return textureSampleLevel(texture_14, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 14u: { return textureSampleLevel(texture_15, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n        case 15u: { return textureSampleLevel(texture_16, default_sampler, tex_coords.xy, layer_index, tex_coords.z); }\n    }\n    return textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, tex_coords.z);\n}\n\n\n\nfn load_texture(tex_coords_and_texture_index: vec3<i32>) -> vec4<f32> {\n    let atlas_index = tex_coords_and_texture_index.z;\n    let layer_index = 0;\n\n    switch (atlas_index) {\n        default { return textureLoad(texture_1, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 1: { return textureLoad(texture_2, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 2: { return textureLoad(texture_3, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 3: { return textureLoad(texture_4, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 4: { return textureLoad(texture_5, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 5: { return textureLoad(texture_6, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 6: { return textureLoad(texture_7, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 7: { return textureLoad(texture_8, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 8: { return textureLoad(texture_9, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 9: { return textureLoad(texture_10, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 10: { return textureLoad(texture_11, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 11: { return textureLoad(texture_12, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 12: { return textureLoad(texture_13, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 13: { return textureLoad(texture_14, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 14: { return textureLoad(texture_15, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n        case 15: { return textureLoad(texture_16, tex_coords_and_texture_index.xy, layer_index, layer_index); }\n    }\n}\n\nfn get_uv(uvs: vec4<f32>, texture_index: u32, coords_set: u32) -> vec3<f32> {\n    //var uv = unpack2x16float(u32(uvs.x));\n    //if (coords_set == 1u) {\n    //    uv = unpack2x16float(u32(uvs.y));\n    //} else if (coords_set == 2u) {\n    //    uv = unpack2x16float(u32(uvs.z));\n    //} else if (coords_set == 3u) {\n    //    uv = unpack2x16float(u32(uvs.w));\n    //}\n    var uv = uvs.xy;\n    if (coords_set == 1u) {\n        uv = uvs.zw;\n    }\n    return vec3<f32>(uv, f32(texture_index));\n}\n\nfn load(texture_index: u32, v: vec2<i32>) -> vec4<f32> {  \n    return load_texture(vec3<i32>(v.xy, i32(texture_index)));\n}\nfn has_texture(material_index: u32, texture_type: u32) -> bool {\n    if (materials.data[material_index].textures_indices[texture_type] >= 0) {\n        return true;\n    }\n    return false;\n}\n\nfn compute_uvs(material_index: u32, texture_type: u32, uv_0_1: vec4<f32>, uv_2_3: vec4<f32>) -> vec3<f32> {\n   let material = &materials.data[material_index];    \n    let texture_coords_set = (*material).textures_coord_set[texture_type];\n    let texture_index = (*material).textures_indices[texture_type];\n    var uv = uv_0_1.xy;\n    if (texture_coords_set == 1u) {\n        uv = uv_0_1.zw;\n    } else if (texture_coords_set == 2u) {\n        uv = uv_2_3.xy;\n    } else if (texture_coords_set == 3u) {\n        uv = uv_2_3.zw;\n    } \n    return vec3<f32>(uv, f32(texture_index));\n}\n\nfn sample_material_texture(gbuffer_uvs: vec4<f32>, material_index: u32, texture_tyoe: u32) -> vec4<f32> {\n    let material = &materials.data[material_index];\n    let texture_id = u32((*material).textures_indices[texture_tyoe]);\n    let coords_set = (*material).textures_coord_set[texture_tyoe];\n    let uv = get_uv(gbuffer_uvs, texture_id, coords_set);\n    return sample_texture(uv);\n}\n\n\nlet PI: f32 = 3.141592653589793;\nlet AMBIENT_COLOR: vec3<f32> = vec3<f32>(0.75, 0.75, 0.75);\nlet AMBIENT_INTENSITY = 0.45;\nlet NULL_VEC4: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 0.0);\nlet MIN_ROUGHNESS = 0.04;\n\nfn compute_alpha(material_index: u32, vertex_color_alpha: f32) -> f32 {\n    let material = &materials.data[material_index];\n    // NOTE: the spec mandates to ignore any alpha value in 'OPAQUE' mode\n    var alpha = 1.;\n    if ((*material).alpha_mode == MATERIAL_ALPHA_BLEND_OPAQUE) {\n        alpha = 1.;\n    } else if ((*material).alpha_mode == MATERIAL_ALPHA_BLEND_MASK) {\n        if (alpha >= (*material).alpha_cutoff) {\n            // NOTE: If rendering as masked alpha and >= the cutoff, render as fully opaque\n            alpha = 1.;\n        } else {\n            // NOTE: output_color.a < material.alpha_cutoff should not is not rendered\n            // NOTE: This and any other discards mean that early-z testing cannot be done!\n            alpha = -1.;\n        }\n    } else if ((*material).alpha_mode == MATERIAL_ALPHA_BLEND_BLEND) {\n        alpha = min((*material).base_color.a, vertex_color_alpha);\n    }\n    return alpha;\n}\n\n\n// The following equation models the Fresnel reflectance term of the spec equation (aka F())\n// Implementation of fresnel from [4], Equation 15\nfn specular_reflection(reflectance0: vec3<f32>, reflectance90: vec3<f32>, VdotH: f32) -> vec3<f32> {\n    return reflectance0 + (reflectance90 - reflectance0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);\n}\n// This calculates the specular geometric attenuation (aka G()),\n// where rougher material will reflect less light back to the viewer.\n// This implementation is based on [1] Equation 4, and we adopt their modifications to\n// alphaRoughness as input as originally proposed in [2].\nfn geometric_occlusion(alpha_roughness: f32, NdotL: f32, NdotV: f32) -> f32 {\n    let r = alpha_roughness;\n\n    let attenuationL = 2.0 * NdotL / (NdotL + sqrt(r * r + (1.0 - r * r) * (NdotL * NdotL)));\n    let attenuationV = 2.0 * NdotV / (NdotV + sqrt(r * r + (1.0 - r * r) * (NdotV * NdotV)));\n    return attenuationL * attenuationV;\n}\n\n// The following equation(s) model the distribution of microfacet normals across the area being drawn (aka D())\n// Implementation from \"Average Irregularity Representation of a Roughened Surface for Ray Reflection\" by T. S. Trowbridge, and K. P. Reitz\n// Follows the distribution function recommended in the SIGGRAPH 2013 course notes from EPIC Games [1], Equation 3.\nfn microfacet_distribution(alpha_roughness: f32, NdotH: f32) -> f32 {\n    let roughnessSq = alpha_roughness * alpha_roughness;\n    let f = (NdotH * roughnessSq - NdotH) * NdotH + 1.0;\n    return roughnessSq / (PI * f * f);\n}\n\nfn pbr(world_pos: vec3<f32>, n: vec3<f32>, material_id: u32, color: vec4<f32>, gbuffer_uvs: vec4<f32>,) -> vec4<f32> {\n    let material = &materials.data[material_id];\n    var perceptual_roughness = (*material).roughness_factor;\n    var metallic = (*material).metallic_factor;\n    if (has_texture(material_id, TEXTURE_TYPE_METALLIC_ROUGHNESS)) {\n        let t = sample_material_texture(gbuffer_uvs, material_id, TEXTURE_TYPE_METALLIC_ROUGHNESS);\n        metallic = metallic * t.b;\n        perceptual_roughness = perceptual_roughness * t.g;\n    }\n    perceptual_roughness = clamp(perceptual_roughness, MIN_ROUGHNESS, 1.0);\n    metallic = clamp(metallic, 0.0, 1.0);\n    // Roughness is authored as perceptual roughness; as is convention,\n    // convert to material roughness by squaring the perceptual roughness [2].\n    let alpha_roughness = perceptual_roughness * perceptual_roughness;\n\n    var ao = 1.0;\n    var occlusion_strength = 1.;\n    if (has_texture(material_id, TEXTURE_TYPE_OCCLUSION)) {\n        let t = sample_material_texture(gbuffer_uvs, material_id, TEXTURE_TYPE_OCCLUSION);\n        ao = ao * t.r;\n        occlusion_strength = (*material).occlusion_strength;\n    }\n    var emissive_color = vec3<f32>(0., 0., 0.);\n    if (has_texture(material_id, TEXTURE_TYPE_EMISSIVE)) {\n        let t = sample_material_texture(gbuffer_uvs, material_id, TEXTURE_TYPE_EMISSIVE);\n        emissive_color = t.rgb * (*material).emissive_color;\n    }\n\n    let f0 = vec3<f32>(0.04, 0.04, 0.04);\n    var diffuse_color = color.rgb * (vec3<f32>(1., 1., 1.) - f0);\n    diffuse_color = diffuse_color * (1.0 - metallic);\n    let specular_color = mix(f0, color.rgb, metallic);        \n\n    // Compute reflectance.\n    let reflectance = max(max(specular_color.r, specular_color.g), specular_color.b);\n\n    // For typical incident reflectance range (between 4% to 100%) set the grazing reflectance to 100% for typical fresnel effect.\n    // For very low reflectance range on highly diffuse objects (below 4%), incrementally reduce grazing reflecance to 0%.\n    let reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);\n    let specular_environmentR0 = specular_color.rgb;\n    let specular_environmentR90 = vec3<f32>(1., 1., 1.) * reflectance90;\n\n    let view_pos = constant_data.view[3].xyz;\n    let v = normalize(view_pos-world_pos);\n\n    let NdotV = clamp(abs(dot(n, v)), 0.0001, 1.0);\n    let reflection = reflect(-v, n);\n    \n    var final_color = color.rgb * AMBIENT_COLOR * AMBIENT_INTENSITY;\n    final_color = mix(final_color, final_color * ao, occlusion_strength);\n    final_color = final_color + emissive_color;\n\n    let num_lights = arrayLength(&lights.data);\n    for (var i = 0u; i < num_lights; i++ ) {\n        let light = &lights.data[i];\n        if ((*light).light_type == 0u) {\n            break;\n        }\n        let dir = (*light).position - world_pos;\n        let l = normalize(dir);                 // Vector from surface point to light\n        let h = normalize(l + v);               // Half vector between both l and v\n        let dist = length(dir);                 // Distance from surface point to light\n\n        let NdotL = clamp(dot(n, l), 0.0001, 1.0);\n        let NdotH = clamp(dot(n, h), 0.0, 1.0);\n        let LdotH = clamp(dot(l, h), 0.0, 1.0);\n        let VdotH = clamp(dot(v, h), 0.0, 1.0);\n        \n        // Calculate the shading terms for the microfacet specular shading model\n        let F = specular_reflection(specular_environmentR0, specular_environmentR90, VdotH);\n        let G = geometric_occlusion(alpha_roughness, NdotL, NdotV);\n        let D = microfacet_distribution(alpha_roughness, NdotH);\n\n        // Calculation of analytical lighting contribution\n        var intensity = max(100., (*light).intensity);\n        intensity = intensity / (4.0 * PI);\n        let range = max(100., (*light).range);\n        let light_contrib = (1. - min(dist / range, 1.)) * intensity;\n        let diffuse_contrib = (1.0 - F) * diffuse_color / PI;\n        let spec_contrib = F * G * D / (4.0 * NdotL * NdotV);\n        var light_color = NdotL * (*light).color.rgb * (diffuse_contrib + spec_contrib);\n        light_color = light_color * light_contrib;\n\n        final_color = final_color + light_color;\n    }\n    \n    return vec4<f32>(final_color, color.a);\n}\n\n\n@compute\n@workgroup_size(64, 1, 1)\nfn main(\n    @builtin(local_invocation_id) local_invocation_id: vec3<u32>, \n    @builtin(local_invocation_index) local_invocation_index: u32, \n    @builtin(global_invocation_id) global_invocation_id: vec3<u32>, \n    @builtin(workgroup_id) workgroup_id: vec3<u32>\n) {\n    let pixel = vec2<i32>(i32(global_invocation_id.x), i32(global_invocation_id.y));\n    if (pixel.x >= i32(pbr_data.width) || pixel.y >= i32(pbr_data.height))\n    {\n        return;\n    }\n    \n    let gbuffer_1 = load(pbr_data.gbuffer_1, pixel);\n    let gbuffer_2 = load(pbr_data.gbuffer_2, pixel);\n\n    var color = vec4<f32>(0., 0., 0., 0.);\n    \n    let mesh_id = u32(gbuffer_2.z);\n    let vertex_color = u32(gbuffer_1.w);\n    if mesh_id == 0u && vertex_color == 1u {\n        textureStore(render_target, pixel.xy, 0, color);\n        return;\n    }\n\n    let display_meshlets = constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS;\n    if (display_meshlets != 0u) {\n        let meshlet_id = hash(u32(gbuffer_2.w));\n        color = vec4<f32>(vec3<f32>(\n            f32(meshlet_id & 255u), \n            f32((meshlet_id >> 8u) & 255u), \n            f32((meshlet_id >> 16u) & 255u)) / 255., \n            1.\n        );\n    } else {\n        let gbuffer_3 = load(pbr_data.gbuffer_3, pixel);\n\n        let material_id = u32(meshes.data[mesh_id].material_index);\n        let texture_color = sample_material_texture(gbuffer_3, material_id, TEXTURE_TYPE_BASE_COLOR);\n        let vertex_color = unpack_unorm_to_4_f32(vertex_color);\n        color = vec4<f32>(vertex_color.rgb * texture_color.rgb, vertex_color.a);\n\n        let alpha = compute_alpha(material_id, vertex_color.a);\n        if alpha < 0. {\n            return;\n        }\n\n        let world_pos = gbuffer_1.xyz;\n        let n = unpack_normal(gbuffer_2.xy);\n        color = pbr(world_pos, n, material_id, color, gbuffer_3);\n    }\n\n    textureStore(render_target, pixel.xy, 0, color);\n}\n"}
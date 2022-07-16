{"spirv_code":[],"wgsl_code":"fn has_texture(material_index: u32, texture_type: u32) -> bool {\n    if (materials.data[material_index].textures_indices[texture_type] >= 0) {\n        return true;\n    }\n    return false;\n}\n\nfn compute_uvs(material_index: u32, texture_type: u32, uv_0_1: vec4<f32>, uv_2_3: vec4<f32>) -> vec3<f32> {\n   let material = &materials.data[material_index];    \n    let texture_coords_set = (*material).textures_coord_set[texture_type];\n    let texture_index = (*material).textures_indices[texture_type];\n    var uv = uv_0_1.xy;\n    if (texture_coords_set == 1u) {\n        uv = uv_0_1.zw;\n    } else if (texture_coords_set == 2u) {\n        uv = uv_2_3.xy;\n    } else if (texture_coords_set == 3u) {\n        uv = uv_2_3.zw;\n    } \n    return vec3<f32>(uv, f32(texture_index));\n}\n\nfn sample_material_texture(gbuffer_uvs: vec4<f32>, material_index: u32, texture_tyoe: u32) -> vec4<f32> {\n    let material = &materials.data[material_index];\n    let texture_id = u32((*material).textures_indices[texture_tyoe]);\n    let coords_set = (*material).textures_coord_set[texture_tyoe];\n    let uv = get_uv(gbuffer_uvs, texture_id, coords_set);\n    return sample_texture(uv);\n}\n"}
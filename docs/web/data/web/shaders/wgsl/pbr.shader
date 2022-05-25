{"spirv_code":[],"wgsl_code":"let MAX_TEXTURE_ATLAS_COUNT: u32 = 16u;\nlet MAX_NUM_LIGHTS: u32 = 64u;\nlet MAX_NUM_TEXTURES: u32 = 512u;\nlet MAX_NUM_MATERIALS: u32 = 512u;\n\nlet TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nlet TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nlet TEXTURE_TYPE_NORMAL: u32 = 2u;\nlet TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nlet TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nlet TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nlet TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nlet TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nlet TEXTURE_TYPE_COUNT: u32 = 8u;\n\nlet MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nlet MATERIAL_ALPHA_BLEND_MASK = 1u;\nlet MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nlet CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nlet CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    flags: u32,\n};\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct ShaderMaterialData {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\nstruct DynamicData {\n    textures_data: array<TextureData, 512>,//MAX_NUM_TEXTURES>,\n    materials_data: array<ShaderMaterialData, 512>,//MAX_NUM_MATERIALS>,\n    lights_data: array<LightData, 64>,//MAX_NUM_LIGHTS>,\n};\n\n\nstruct VertexInput {\n    @builtin(vertex_index) index: u32,\n    @location(0) position: vec3<f32>,\n    @location(1) normal: vec3<f32>,\n    @location(2) tangent: vec4<f32>,\n    @location(3) color: vec4<f32>,\n    @location(4) tex_coords_0: vec2<f32>,\n    @location(5) tex_coords_1: vec2<f32>,\n    @location(6) tex_coords_2: vec2<f32>,\n    @location(7) tex_coords_3: vec2<f32>,\n};\n\nstruct InstanceInput {\n    @builtin(instance_index) index: u32,\n    @location(8) draw_area: vec4<f32>,\n    @location(9) model_matrix_0: vec4<f32>,\n    @location(10) model_matrix_1: vec4<f32>,\n    @location(11) model_matrix_2: vec4<f32>,\n    @location(12) model_matrix_3: vec4<f32>,\n    @location(13) material_index: i32,\n};\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) world_position: vec4<f32>,\n    @location(1) color: vec4<f32>,\n    @location(2) world_normal: vec3<f32>,\n    @location(3) world_tangent: vec4<f32>,\n    @location(4) view: vec3<f32>,\n    @location(5) @interpolate(flat) material_index: i32,\n    @location(6) tex_coords_base_color: vec2<f32>,\n    @location(7) tex_coords_metallic_roughness: vec2<f32>,\n    @location(8) tex_coords_normal: vec2<f32>,\n    @location(9) tex_coords_emissive: vec2<f32>,\n    @location(10) tex_coords_occlusion: vec2<f32>,\n    @location(11) tex_coords_specular_glossiness: vec2<f32>,\n    @location(12) tex_coords_diffuse: vec2<f32>,\n};\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read> dynamic_data: DynamicData;\n\n@group(1) @binding(0)\nvar default_sampler: sampler;\n@group(1) @binding(1)\nvar depth_sampler: sampler_comparison;\n\n@group(1) @binding(2)\nvar texture_1: texture_2d_array<f32>;\n@group(1) @binding(3)\nvar texture_2: texture_2d_array<f32>;\n@group(1) @binding(4)\nvar texture_3: texture_2d_array<f32>;\n@group(1) @binding(5)\nvar texture_4: texture_2d_array<f32>;\n@group(1) @binding(6)\nvar texture_5: texture_2d_array<f32>;\n@group(1) @binding(7)\nvar texture_6: texture_2d_array<f32>;\n@group(1) @binding(8)\nvar texture_7: texture_2d_array<f32>;\n@group(1) @binding(9)\nvar texture_8: texture_2d_array<f32>;\n@group(1) @binding(10)\nvar texture_9: texture_2d_array<f32>;\n@group(1) @binding(11)\nvar texture_10: texture_2d_array<f32>;\n@group(1) @binding(12)\nvar texture_11: texture_2d_array<f32>;\n@group(1) @binding(13)\nvar texture_12: texture_2d_array<f32>;\n@group(1) @binding(14)\nvar texture_13: texture_2d_array<f32>;\n@group(1) @binding(15)\nvar texture_14: texture_2d_array<f32>;\n@group(1) @binding(16)\nvar texture_15: texture_2d_array<f32>;\n@group(1) @binding(17)\nvar texture_16: texture_2d_array<f32>;\n\nfn get_textures_coord_set(v: VertexInput, material_index: i32, texture_type: u32) -> vec2<f32> {\n    let textures_coord_set_index = dynamic_data.materials_data[material_index].textures_coord_set[texture_type];\n    if (textures_coord_set_index == 1u) {\n        return v.tex_coords_1;\n    } else if (textures_coord_set_index == 2u) {\n        return v.tex_coords_2;\n    } else if (textures_coord_set_index == 3u) {\n        return v.tex_coords_3;\n    }\n    return v.tex_coords_0;\n}\n\n\nfn inverse_transpose_3x3(m: mat3x3<f32>) -> mat3x3<f32> {\n    let x = cross(m[1], m[2]);\n    let y = cross(m[2], m[0]);\n    let z = cross(m[0], m[1]);\n    let det = dot(m[2], z);\n    return mat3x3<f32>(\n        x / det,\n        y / det,\n        z / det\n    );\n}\n\nfn rand(n: u32) -> f32 {    \n    // integer hash copied from Hugo Elias\n    let n = (n << 13u) ^ n;\n    let n = n * (n * n * 15731u + 789221u) + 1376312589u;\n    return f32(n & u32(0x7fffffff)) / f32(0x7fffffff);\n}\n\nfn random_color(v: u32) -> vec3<f32> {\n    let v1 = rand(v * 100u);\n    let v2 = rand(v);\n    let v3 = rand(u32(v1 - v2));\n    return vec3(v1, v2, v3);\n}\n\n\n@vertex\nfn vs_main(\n    v: VertexInput,\n    instance: InstanceInput,\n) -> VertexOutput {\n    let instance_matrix = mat4x4<f32>(\n        instance.model_matrix_0,\n        instance.model_matrix_1,\n        instance.model_matrix_2,\n        instance.model_matrix_3,\n    );\n    let normal_matrix = mat3x3<f32>(\n        instance.model_matrix_0.xyz,\n        instance.model_matrix_1.xyz,\n        instance.model_matrix_2.xyz,\n    );\n    let inv_normal_matrix = inverse_transpose_3x3(normal_matrix);\n\n    var vertex_out: VertexOutput;\n    vertex_out.world_position = instance_matrix * vec4<f32>(v.position, 1.0);\n    vertex_out.clip_position = constant_data.proj * constant_data.view * vertex_out.world_position;\n    vertex_out.world_normal = inv_normal_matrix * v.normal;\n    vertex_out.world_tangent = vec4<f32>(normal_matrix * v.tangent.xyz, v.tangent.w);\n    let view_pos = constant_data.view[3].xyz;\n    vertex_out.view = view_pos - vertex_out.world_position.xyz;\n    vertex_out.color = v.color;\n    vertex_out.material_index = instance.material_index;\n\n    let display_meshlets = constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS;\n    if (display_meshlets != 0u) {\n        let c = random_color(instance.index + v.index / 64u);\n        vertex_out.color = vec4<f32>(c, 1.0);\n    } else if (instance.material_index >= 0) {\n        vertex_out.tex_coords_base_color = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_BASE_COLOR);\n        vertex_out.tex_coords_metallic_roughness = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_METALLIC_ROUGHNESS);\n        vertex_out.tex_coords_normal = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_NORMAL);\n        vertex_out.tex_coords_emissive = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_EMISSIVE);\n        vertex_out.tex_coords_occlusion = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_OCCLUSION);\n        vertex_out.tex_coords_specular_glossiness = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_SPECULAR_GLOSSINESS);\n        vertex_out.tex_coords_diffuse = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_DIFFUSE);\n    }\n\n    return vertex_out;\n}\n\nfn has_texture(material_index: i32, texture_type: u32) -> bool {\n    if (material_index < 0) {\n        return false;\n    }\n    if (dynamic_data.materials_data[u32(material_index)].textures_indices[texture_type] >= 0) {\n        return true;\n    }\n    return false;\n}\n\nfn wrap(a: f32, min: f32, max: f32) -> f32 {\n    if (a < min) {\n        return max - (min - a);\n    }\n    if (a > max) {\n        return min + (a - max);\n    }\n    return a;\n}\n\nfn get_texture_color(material_index: i32, texture_type: u32, tex_coords: vec2<f32>) -> vec4<f32> {\n    if (material_index < 0) {\n        return vec4<f32>(0.0, 0.0, 0.0, 0.0);\n    }\n    let texture_data_index = dynamic_data.materials_data[material_index].textures_indices[texture_type];\n    var t = vec3<f32>(0.0, 0.0, 0.0);\n    let area = dynamic_data.textures_data[texture_data_index].area;\n    let image_width = dynamic_data.textures_data[texture_data_index].total_width;\n    let image_height = dynamic_data.textures_data[texture_data_index].total_height;\n    let fract_x = min(fract(tex_coords.x), 1.0);\n    let fract_y = min(fract(tex_coords.y), 1.0);\n    t.x = (area.x + 0.5 + area.z * fract_x) / image_width;\n    t.y = (area.y + 0.5 + area.w * fract_y) / image_height;\n    t.z = f32(dynamic_data.textures_data[texture_data_index].layer_index);\n\n    let atlas_index = dynamic_data.textures_data[texture_data_index].texture_index;\n    let layer_index = i32(dynamic_data.textures_data[texture_data_index].layer_index);\n\n    if (atlas_index == 1u) {\n        return textureSampleLevel(texture_2, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 2u) {\n        return textureSampleLevel(texture_3, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 3u) {\n        return textureSampleLevel(texture_4, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 4u) {\n        return textureSampleLevel(texture_5, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 5u) {\n        return textureSampleLevel(texture_6, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 6u) {\n        return textureSampleLevel(texture_7, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 7u) {\n        return textureSampleLevel(texture_8, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 8u) {\n        return textureSampleLevel(texture_9, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 9u) {\n        return textureSampleLevel(texture_10, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 10u) {\n        return textureSampleLevel(texture_11, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 11u) {\n        return textureSampleLevel(texture_12, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 12u) {\n        return textureSampleLevel(texture_13, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 13u) {\n        return textureSampleLevel(texture_14, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 14u) {\n        return textureSampleLevel(texture_15, default_sampler, t.xy, layer_index, t.z);\n    } else if (atlas_index == 15u) {\n        return textureSampleLevel(texture_16, default_sampler, t.xy, layer_index, t.z);\n    }\n    return textureSampleLevel(texture_1, default_sampler, t.xy, layer_index, t.z);\n}\n\n// References:\n// [1] Real Shading in Unreal Engine 4\n//     http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf\n// [2] Physically Based Shading at Disney\n//     http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf\n// [3] README.md - Environment Maps\n//     https://github.com/KhronosGroup/glTF-WebGL-PBR/#environment-maps\n// [4] \"An Inexpensive BRDF Model for Physically based Rendering\" by Christophe Schlick\n//     https://www.cs.virginia.edu/~jdl/bib/appearance/analytic%20models/schlick94b.pdf\nstruct PBRInfo {\n    NdotL: f32,                  // cos angle between normal and light direction\n    NdotV: f32,                  // cos angle between normal and view direction\n    NdotH: f32,                  // cos angle between normal and half vector\n    LdotH: f32,                  // cos angle between light direction and half vector\n    VdotH: f32,                  // cos angle between view direction and half vector\n    perceptual_roughness: f32,   // roughness value, as authored by the model creator (input to shader)\n    metalness: f32,              // metallic value at the surface\n    alpha_roughness: f32,        // roughness mapped to a more linear change in the roughness (proposed by [2])\n    reflectance0: vec3<f32>,     // full reflectance color (normal incidence angle)\n    reflectance90: vec3<f32>,    // reflectance color at grazing angle\n    diffuse_color: vec3<f32>,    // color contribution from diffuse lighting\n    specular_color: vec3<f32>,   // color contribution from specular lighting\n};\n\n\nlet PI: f32 = 3.141592653589793;\nlet AMBIENT_COLOR: vec3<f32> = vec3<f32>(0.75, 0.75, 0.75);\nlet AMBIENT_INTENSITY = 0.45;\nlet NULL_VEC4: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 0.0);\nlet MinRoughness = 0.04;\n\n// Find the normal for this fragment, pulling either from a predefined normal map\n// or from the interpolated mesh normal and tangent attributes.\nfn normal(v: VertexOutput) -> vec3<f32> {\n    // Retrieve the tangent space matrix\n    var n = normalize(v.world_normal);\n    if (has_texture(v.material_index, TEXTURE_TYPE_NORMAL)) {\n        var t = normalize(v.world_tangent.xyz - n * dot(v.world_tangent.xyz, n));\n        var b = cross(n, t) * v.world_tangent.w;\n        let tbn = mat3x3<f32>(t, b, n);\n        let normal = get_texture_color(v.material_index, TEXTURE_TYPE_NORMAL, v.tex_coords_normal);\n        n = tbn * (2.0 * normal.rgb - vec3<f32>(1.0));\n        n = normalize(n);\n    }\n    \n    //being front-facing culling we've to revert\n    //n = -n;\n\n    return n;\n}\n// Basic Lambertian diffuse\n// Implementation from Lambert's Photometria https://archive.org/details/lambertsphotome00lambgoog\n// See also [1], Equation 1\nfn diffuse(info: PBRInfo) -> vec3<f32> {\n    return info.diffuse_color / PI;\n}\n// The following equation models the Fresnel reflectance term of the spec equation (aka F())\n// Implementation of fresnel from [4], Equation 15\nfn specular_reflection(info: PBRInfo) -> vec3<f32> {\n    return info.reflectance0 + (info.reflectance90 - info.reflectance0) * pow(clamp(1.0 - info.VdotH, 0.0, 1.0), 5.0);\n}\n// This calculates the specular geometric attenuation (aka G()),\n// where rougher material will reflect less light back to the viewer.\n// This implementation is based on [1] Equation 4, and we adopt their modifications to\n// alphaRoughness as input as originally proposed in [2].\nfn geometric_occlusion(info: PBRInfo) -> f32 {\n    let r = info.alpha_roughness;\n\n    let attenuationL = 2.0 * info.NdotL / (info.NdotL + sqrt(r * r + (1.0 - r * r) * (info.NdotL * info.NdotL)));\n    let attenuationV = 2.0 * info.NdotV / (info.NdotV + sqrt(r * r + (1.0 - r * r) * (info.NdotV * info.NdotV)));\n    return attenuationL * attenuationV;\n}\n\n// The following equation(s) model the distribution of microfacet normals across the area being drawn (aka D())\n// Implementation from \"Average Irregularity Representation of a Roughened Surface for Ray Reflection\" by T. S. Trowbridge, and K. P. Reitz\n// Follows the distribution function recommended in the SIGGRAPH 2013 course notes from EPIC Games [1], Equation 3.\nfn microfacet_distribution(info: PBRInfo) -> f32 {\n    let roughnessSq = info.alpha_roughness * info.alpha_roughness;\n    let f = (info.NdotH * roughnessSq - info.NdotH) * info.NdotH + 1.0;\n    return roughnessSq / (PI * f * f);\n}\n\n\n@fragment\nfn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {\n    if (v_in.material_index < 0) {\n        discard;\n    }\n\n    let display_meshlets = constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS;\n    if (display_meshlets != 0u) {\n        return v_in.color;\n    }\n\n    let material = dynamic_data.materials_data[v_in.material_index];\n\n    var base_color = min(v_in.color, material.base_color);\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_BASE_COLOR)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_BASE_COLOR, v_in.tex_coords_base_color);\n        base_color = base_color * t;\n    }\n    \n    // NOTE: the spec mandates to ignore any alpha value in 'OPAQUE' mode\n    var alpha = 1.;\n    if (material.alpha_mode == MATERIAL_ALPHA_BLEND_OPAQUE) {\n        alpha = 1.0;\n    } else if (material.alpha_mode == MATERIAL_ALPHA_BLEND_MASK) {\n        if (alpha >= material.alpha_cutoff) {\n            // NOTE: If rendering as masked alpha and >= the cutoff, render as fully opaque\n            alpha = 1.0;\n        } else {\n            // NOTE: output_color.a < material.alpha_cutoff should not is not rendered\n            // NOTE: This and any other discards mean that early-z testing cannot be done!\n            discard;\n        }\n    } else if (material.alpha_mode == MATERIAL_ALPHA_BLEND_BLEND) {\n        alpha = min(material.base_color.a, base_color.a);\n    }\n    \n    // Metallic and Roughness material properties are packed together\n    // In glTF, these factors can be specified by fixed scalar values\n    // or from a metallic-roughness map\n    var perceptual_roughness = material.roughness_factor;\n    var metallic = material.metallic_factor;\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_METALLIC_ROUGHNESS)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_METALLIC_ROUGHNESS, v_in.tex_coords_metallic_roughness);\n        metallic = metallic * t.b;\n        perceptual_roughness = perceptual_roughness * t.g;\n    }\n    perceptual_roughness = clamp(perceptual_roughness, MinRoughness, 1.0);\n    metallic = clamp(metallic, 0.0, 1.0);\n    // Roughness is authored as perceptual roughness; as is convention,\n    // convert to material roughness by squaring the perceptual roughness [2].\n    let alpha_roughness = perceptual_roughness * perceptual_roughness;\n\n    var ao = 1.0;\n    var occlusion_strength = 1.;\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_OCCLUSION)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_OCCLUSION, v_in.tex_coords_occlusion);\n        ao = ao * t.r;\n        occlusion_strength = material.occlusion_strength;\n    }\n    var emissive_color = vec3<f32>(0., 0., 0.);\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_EMISSIVE)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_EMISSIVE, v_in.tex_coords_emissive);\n        emissive_color = t.rgb * material.emissive_color;\n    }\n\n    let f0 = vec3<f32>(0.04, 0.04, 0.04);\n    var diffuse_color = base_color.rgb * (vec3<f32>(1., 1., 1.) - f0);\n    diffuse_color = diffuse_color * (1.0 - metallic);\n    let specular_color = mix(f0, base_color.rgb, metallic);\n\n    // Compute reflectance.\n    let reflectance = max(max(specular_color.r, specular_color.g), specular_color.b);\n\n    // For typical incident reflectance range (between 4% to 100%) set the grazing reflectance to 100% for typical fresnel effect.\n    // For very low reflectance range on highly diffuse objects (below 4%), incrementally reduce grazing reflecance to 0%.\n    let reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);\n    let specular_environmentR0 = specular_color.rgb;\n    let specular_environmentR90 = vec3<f32>(1., 1., 1.) * reflectance90;\n\n    let n = normal(v_in);                             // normal at surface point\n    let v = normalize(v_in.view);        // Vector from surface point to camera\n    let NdotV = clamp(abs(dot(n, v)), 0.0001, 1.0);\n    let reflection = reflect(-v, n);\n\n    var color = base_color.rgb * AMBIENT_COLOR * AMBIENT_INTENSITY;\n    color = mix(color, color * ao, occlusion_strength);\n    color = color + emissive_color;\n\n    var i = 0u;\n    loop {\n        let light = dynamic_data.lights_data[i];\n        if (dynamic_data.lights_data[i].light_type == 0u) {\n            break;\n        }\n        let l = normalize(light.position - v_in.world_position.xyz);             // Vector from surface point to light\n        let h = normalize(l + v);                          // Half vector between both l and v\n        let dist = length(light.position - v_in.world_position.xyz);                                // Distance from surface point to light\n\n        let NdotL = clamp(dot(n, l), 0.0001, 1.0);\n        let NdotH = clamp(dot(n, h), 0.0, 1.0);\n        let LdotH = clamp(dot(l, h), 0.0, 1.0);\n        let VdotH = clamp(dot(v, h), 0.0, 1.0);\n\n        let info = PBRInfo(\n            NdotL,\n            NdotV,\n            NdotH,\n            LdotH,\n            VdotH,\n            perceptual_roughness,\n            metallic,\n            alpha_roughness,\n            specular_environmentR0,\n            specular_environmentR90,\n            diffuse_color,\n            specular_color\n        );\n        \n        // Calculate the shading terms for the microfacet specular shading model\n        let F = specular_reflection(info);\n        let G = geometric_occlusion(info);\n        let D = microfacet_distribution(info);\n\n        // Calculation of analytical lighting contribution\n        var intensity = max(200., light.intensity);\n        intensity = intensity / (4.0 * PI);\n        let range = max(5., light.range);\n        let light_contrib = (1. - min(dist / range, 1.)) * intensity;\n        let diffuse_contrib = (1.0 - F) * diffuse(info);\n        let spec_contrib = F * G * D / (4.0 * NdotL * NdotV);\n        var light_color = NdotL * light.color.rgb * (diffuse_contrib + spec_contrib);\n        light_color = light_color * light_contrib;\n\n        color = color + light_color;\n\n        i = i + 1u;\n    }\n    // TODO!: apply fix from reference shader:\n    // https://github.com/KhronosGroup/glTF-WebGL-PBR/pull/55/files#diff-f7232333b020880432a925d5a59e075d\n    let frag_color = vec4<f32>(color.rgb, alpha);\n    return frag_color;\n}\n"}
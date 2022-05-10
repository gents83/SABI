{"spirv_code":[],"wgsl_code":"let MAX_TEXTURE_ATLAS_COUNT: u32 = 16u;\nlet MAX_NUM_LIGHTS: u32 = 64u;\nlet MAX_NUM_TEXTURES: u32 = 512u;\nlet MAX_NUM_MATERIALS: u32 = 512u;\n\nlet TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nlet TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nlet TEXTURE_TYPE_NORMAL: u32 = 2u;\nlet TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nlet TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nlet TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nlet TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nlet TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nlet TEXTURE_TYPE_COUNT: u32 = 8u;\n\nlet MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nlet MATERIAL_ALPHA_BLEND_MASK = 1u;\nlet MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nlet CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nlet CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    flags: u32,\n};\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct ShaderMaterialData {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\nstruct DynamicData {\n    textures_data: array<TextureData, 512>,//MAX_NUM_TEXTURES>,\n    materials_data: array<ShaderMaterialData, 512>,//MAX_NUM_MATERIALS>,\n    lights_data: array<LightData, 64>,//MAX_NUM_LIGHTS>,\n};\n\n\nstruct VertexInput {\n    //@builtin(vertex_index) index: u32,\n    @location(0) position: vec3<f32>,\n    @location(1) normal: vec3<f32>,\n    @location(2) tangent: vec4<f32>,\n    @location(3) color: vec4<f32>,\n    @location(4) tex_coords_0: vec2<f32>,\n    @location(5) tex_coords_1: vec2<f32>,\n    @location(6) tex_coords_2: vec2<f32>,\n    @location(7) tex_coords_3: vec2<f32>,\n};\n\nstruct InstanceInput {\n    //@builtin(instance_index) index: u32,\n    @location(8) draw_area: vec4<f32>,\n    @location(9) model_matrix_0: vec4<f32>,\n    @location(10) model_matrix_1: vec4<f32>,\n    @location(11) model_matrix_2: vec4<f32>,\n    @location(12) model_matrix_3: vec4<f32>,\n    @location(13) material_index: i32,\n};\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    //@builtin(front_facing) is_front_facing: bool,\n    @location(0) world_position: vec4<f32>,\n    @location(1) world_normal: vec3<f32>,\n    @location(2) world_tangent: vec4<f32>,\n    @location(3) color: vec4<f32>,\n    @location(4) @interpolate(flat) material_index: i32,\n    @location(5) tex_coords_base_color: vec2<f32>,\n    @location(6) tex_coords_metallic_roughness: vec2<f32>,\n    @location(7) tex_coords_normal: vec2<f32>,\n    @location(8) tex_coords_emissive: vec2<f32>,\n    @location(9) tex_coords_occlusion: vec2<f32>,\n    @location(10) tex_coords_specular_glossiness: vec2<f32>,\n    @location(11) tex_coords_diffuse: vec2<f32>,\n};\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read> dynamic_data: DynamicData;\n\n@group(1) @binding(0)\nvar default_sampler: sampler;\n@group(1) @binding(1)\nvar depth_sampler: sampler_comparison;\n\n@group(1) @binding(2)\nvar texture_1: texture_2d<f32>;\n@group(1) @binding(3)\nvar texture_2: texture_2d<f32>;\n@group(1) @binding(4)\nvar texture_3: texture_2d<f32>;\n@group(1) @binding(5)\nvar texture_4: texture_2d<f32>;\n@group(1) @binding(6)\nvar texture_5: texture_2d<f32>;\n@group(1) @binding(7)\nvar texture_6: texture_2d<f32>;\n@group(1) @binding(8)\nvar texture_7: texture_2d<f32>;\n@group(1) @binding(9)\nvar texture_8: texture_2d<f32>;\n@group(1) @binding(10)\nvar texture_9: texture_2d<f32>;\n@group(1) @binding(11)\nvar texture_10: texture_2d<f32>;\n@group(1) @binding(12)\nvar texture_11: texture_2d<f32>;\n@group(1) @binding(13)\nvar texture_12: texture_2d<f32>;\n@group(1) @binding(14)\nvar texture_13: texture_2d<f32>;\n@group(1) @binding(15)\nvar texture_14: texture_2d<f32>;\n@group(1) @binding(16)\nvar texture_15: texture_2d<f32>;\n@group(1) @binding(17)\nvar texture_16: texture_2d<f32>;\n\nfn inverse_transpose_3x3(m: mat3x3<f32>) -> mat3x3<f32> {\n    let x = cross(m[1], m[2]);\n    let y = cross(m[2], m[0]);\n    let z = cross(m[0], m[1]);\n    let det = dot(m[2], z);\n    return mat3x3<f32>(\n        x / det,\n        y / det,\n        z / det\n    );\n}\n\nfn get_textures_coord_set(v: VertexInput, material_index: i32, texture_type: u32) -> vec2<f32> {\n    let textures_coord_set_index = dynamic_data.materials_data[material_index].textures_coord_set[texture_type];\n    if (textures_coord_set_index == 1u) {\n        return v.tex_coords_1;\n    } else if (textures_coord_set_index == 2u) {\n        return v.tex_coords_2;\n    } else if (textures_coord_set_index == 3u) {\n        return v.tex_coords_3;\n    }\n    return v.tex_coords_0;\n}\n\n\n@vertex\nfn vs_main(\n    v: VertexInput,\n    instance: InstanceInput,\n) -> VertexOutput {\n    let instance_matrix = mat4x4<f32>(\n        instance.model_matrix_0,\n        instance.model_matrix_1,\n        instance.model_matrix_2,\n        instance.model_matrix_3,\n    );\n    let normal_matrix = mat3x3<f32>(\n        instance.model_matrix_0.xyz,\n        instance.model_matrix_1.xyz,\n        instance.model_matrix_2.xyz,\n    );\n    let inv_normal_matrix = inverse_transpose_3x3(normal_matrix);\n\n    var vertex_out: VertexOutput;\n    vertex_out.world_position = instance_matrix * vec4<f32>(v.position, 1.0);\n    vertex_out.clip_position = constant_data.proj * constant_data.view * vertex_out.world_position;\n    vertex_out.world_normal = inv_normal_matrix * v.normal;\n    vertex_out.world_tangent = vec4<f32>(normal_matrix * v.tangent.xyz, v.tangent.w);\n    vertex_out.color = v.color;\n    vertex_out.material_index = instance.material_index;\n\n    if (instance.material_index >= 0) {\n        vertex_out.tex_coords_base_color = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_BASE_COLOR);\n        vertex_out.tex_coords_metallic_roughness = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_METALLIC_ROUGHNESS);\n        vertex_out.tex_coords_normal = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_NORMAL);\n        vertex_out.tex_coords_emissive = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_EMISSIVE);\n        vertex_out.tex_coords_occlusion = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_OCCLUSION);\n        vertex_out.tex_coords_specular_glossiness = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_SPECULAR_GLOSSINESS);\n        vertex_out.tex_coords_diffuse = get_textures_coord_set(v, instance.material_index, TEXTURE_TYPE_DIFFUSE);\n    }\n\n    return vertex_out;\n}\n\nfn has_texture(material_index: i32, texture_type: u32) -> bool {\n    if (material_index < 0) {\n        return false;\n    }\n    if (dynamic_data.materials_data[u32(material_index)].textures_indices[texture_type] >= 0) {\n        return true;\n    }\n    return false;\n}\n\nfn wrap(a: f32, min: f32, max: f32) -> f32 {\n    if (a < min) {\n        return max - (min - a);\n    }\n    if (a > max) {\n        return min + (a - max);\n    }\n    return a;\n}\n\nfn get_texture_color(material_index: i32, texture_type: u32, tex_coords: vec2<f32>) -> vec4<f32> {\n    if (material_index < 0) {\n        return vec4<f32>(0.0, 0.0, 0.0, 0.0);\n    }\n    let texture_data_index = dynamic_data.materials_data[material_index].textures_indices[texture_type];\n    var t = vec3<f32>(0.0, 0.0, 0.0);\n    let area = dynamic_data.textures_data[texture_data_index].area;\n    let image_width = dynamic_data.textures_data[texture_data_index].total_width;\n    let image_height = dynamic_data.textures_data[texture_data_index].total_height;\n    let fract_x = min(fract(tex_coords.x), 1.0);\n    let fract_y = min(fract(tex_coords.y), 1.0);\n    t.x = (area.x + 0.5 + area.z * fract_x) / image_width;\n    t.y = (area.y + 0.5 + area.w * fract_y) / image_height;\n    t.z = f32(dynamic_data.textures_data[texture_data_index].layer_index);\n\n    let atlas_index = dynamic_data.textures_data[texture_data_index].texture_index;\n    if (atlas_index == 1u) {\n        return textureSampleLevel(texture_2, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 2u) {\n        return textureSampleLevel(texture_3, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 3u) {\n        return textureSampleLevel(texture_4, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 4u) {\n        return textureSampleLevel(texture_5, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 5u) {\n        return textureSampleLevel(texture_6, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 6u) {\n        return textureSampleLevel(texture_7, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 7u) {\n        return textureSampleLevel(texture_8, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 8u) {\n        return textureSampleLevel(texture_9, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 9u) {\n        return textureSampleLevel(texture_10, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 10u) {\n        return textureSampleLevel(texture_11, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 11u) {\n        return textureSampleLevel(texture_12, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 12u) {\n        return textureSampleLevel(texture_13, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 13u) {\n        return textureSampleLevel(texture_14, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 14u) {\n        return textureSampleLevel(texture_15, default_sampler, t.xy, t.z);\n    } else if (atlas_index == 15u) {\n        return textureSampleLevel(texture_16, default_sampler, t.xy, t.z);\n    }\n    return textureSampleLevel(texture_1, default_sampler, t.xy, t.z);\n}\n\nlet PI: f32 = 3.141592653589793;\nlet AMBIENT_COLOR: vec3<f32> = vec3<f32>(0.95, 0.95, 0.95);\nlet NULL_VEC4: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 0.0);\n\n// From https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile\nfn EnvBRDFApprox(f0: vec3<f32>, perceptual_roughness: f32, NoV: f32) -> vec3<f32> {\n    let c0 = vec4<f32>(-1.0, -0.0275, -0.572, 0.022);\n    let c1 = vec4<f32>(1.0, 0.0425, 1.04, -0.04);\n    let r = perceptual_roughness * c0 + c1;\n    let a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;\n    let AB = vec2<f32>(-1.04, 1.04) * a004 + r.zw;\n    return f0 * AB.x + AB.y;\n}\n\nfn perceptualRoughnessToRoughness(perceptualRoughness: f32) -> f32 {\n    // clamp perceptual roughness to prevent precision problems\n    // According to Filament design 0.089 is recommended for mobile\n    // Filament uses 0.045 for non-mobile\n    let clampedPerceptualRoughness = clamp(perceptualRoughness, 0.089, 1.0);\n    return clampedPerceptualRoughness * clampedPerceptualRoughness;\n}\n\n// luminance coefficients from Rec. 709.\n// https://en.wikipedia.org/wiki/Rec._709\nfn luminance(v: vec3<f32>) -> f32 {\n    return dot(v, vec3<f32>(0.2126, 0.7152, 0.0722));\n}\n\nfn change_luminance(c_in: vec3<f32>, l_out: f32) -> vec3<f32> {\n    let l_in = luminance(c_in);\n    return c_in * (l_out / l_in);\n}\n\nfn reinhard_luminance(color: vec3<f32>) -> vec3<f32> {\n    let l_old = luminance(color);\n    let l_new = l_old / (1.0 + l_old);\n    return change_luminance(color, l_new);\n}\n\nfn saturate(value: f32) -> f32 {\n    return clamp(value, 0.0, 1.0);\n}\n\n// distanceAttenuation is simply the square falloff of light intensity\n// combined with a smooth attenuation at the edge of the light radius\n//\n// light radius is a non-physical construct for efficiency purposes,\n// because otherwise every light affects every fragment in the scene\nfn getDistanceAttenuation(distanceSquare: f32, inverseRangeSquared: f32) -> f32 {\n    let factor = distanceSquare * inverseRangeSquared;\n    let smoothFactor = saturate(1.0 - factor * factor);\n    let attenuation = smoothFactor * smoothFactor;\n    return attenuation * 1.0 / max(distanceSquare, 0.0001);\n}\n\n// Normal distribution function (specular D)\n// Based on https://google.github.io/filament/Filament.html#citation-walter07\n\n// D_GGX(h,α) = α^2 / { π ((n⋅h)^2 (α2−1) + 1)^2 }\n\n// Simple implementation, has precision problems when using fp16 instead of fp32\n// see https://google.github.io/filament/Filament.html#listing_speculardfp16\nfn D_GGX(roughness: f32, NoH: f32, h: vec3<f32>) -> f32 {\n    let oneMinusNoHSquared = 1.0 - NoH * NoH;\n    let a = NoH * roughness;\n    let k = roughness / (oneMinusNoHSquared + a * a);\n    let d = k * k * (1.0 / PI);\n    return d;\n}\n\n// Visibility function (Specular G)\n// V(v,l,a) = G(v,l,α) / { 4 (n⋅v) (n⋅l) }\n// such that f_r becomes\n// f_r(v,l) = D(h,α) V(v,l,α) F(v,h,f0)\n// where\n// V(v,l,α) = 0.5 / { n⋅l sqrt((n⋅v)^2 (1−α2) + α2) + n⋅v sqrt((n⋅l)^2 (1−α2) + α2) }\n// Note the two sqrt's, that may be slow on mobile, see https://google.github.io/filament/Filament.html#listing_approximatedspecularv\nfn V_SmithGGXCorrelated(roughness: f32, NoV: f32, NoL: f32) -> f32 {\n    let a2 = roughness * roughness;\n    let lambdaV = NoL * sqrt((NoV - a2 * NoV) * NoV + a2);\n    let lambdaL = NoV * sqrt((NoL - a2 * NoL) * NoL + a2);\n    let v = 0.5 / (lambdaV + lambdaL);\n    return v;\n}\n\n// Fresnel function\n// see https://google.github.io/filament/Filament.html#citation-schlick94\n// F_Schlick(v,h,f_0,f_90) = f_0 + (f_90 − f_0) (1 − v⋅h)^5\nfn F_Schlick_vec(f0: vec3<f32>, f90: f32, VoH: f32) -> vec3<f32> {\n    // not using mix to keep the vec3 and float versions identical\n    return f0 + (f90 - f0) * pow(1.0 - VoH, 5.0);\n}\n\nfn F_Schlick(f0: f32, f90: f32, VoH: f32) -> f32 {\n    // not using mix to keep the vec3 and float versions identical\n    return f0 + (f90 - f0) * pow(1.0 - VoH, 5.0);\n}\n\nfn fresnel(f0: vec3<f32>, LoH: f32) -> vec3<f32> {\n    // f_90 suitable for ambient occlusion\n    // see https://google.github.io/filament/Filament.html#lighting/occlusion\n    let f90 = saturate(dot(f0, vec3<f32>(50.0 * 0.33)));\n    return F_Schlick_vec(f0, f90, LoH);\n}\n\n// Specular BRDF\n// https://google.github.io/filament/Filament.html#materialsystem/specularbrdf\n\n// Cook-Torrance approximation of the microfacet model integration using Fresnel law F to model f_m\n// f_r(v,l) = { D(h,α) G(v,l,α) F(v,h,f0) } / { 4 (n⋅v) (n⋅l) }\nfn specular(f0: vec3<f32>, roughness: f32, h: vec3<f32>, NoV: f32, NoL: f32, NoH: f32, LoH: f32, specularIntensity: f32) -> vec3<f32> {\n    let D = D_GGX(roughness, NoH, h);\n    let V = V_SmithGGXCorrelated(roughness, NoV, NoL);\n    let F = fresnel(f0, LoH);\n\n    return (specularIntensity * D * V) * F;\n}\n\n// Diffuse BRDF\n// https://google.github.io/filament/Filament.html#materialsystem/diffusebrdf\n// fd(v,l) = σ/π * 1 / { |n⋅v||n⋅l| } ∫Ω D(m,α) G(v,l,m) (v⋅m) (l⋅m) dm\n//\n// simplest approximation\n// float Fd_Lambert() {\n//     return 1.0 / PI;\n// }\n//\n// vec3 Fd = diffuseColor * Fd_Lambert();\n//\n// Disney approximation\n// See https://google.github.io/filament/Filament.html#citation-burley12\n// minimal quality difference\nfn Fd_Burley(roughness: f32, NoV: f32, NoL: f32, LoH: f32) -> f32 {\n    let f90 = 0.5 + 2.0 * roughness * LoH * LoH;\n    let lightScatter = F_Schlick(1.0, f90, NoL);\n    let viewScatter = F_Schlick(1.0, f90, NoV);\n    return lightScatter * viewScatter * (1.0 / PI);\n}\n\nfn point_light(\n    world_position: vec3<f32>,\n    light: LightData,\n    roughness: f32,\n    NdotV: f32,\n    N: vec3<f32>,\n    V: vec3<f32>,\n    R: vec3<f32>,\n    F0: vec3<f32>,\n    diffuseColor: vec3<f32>\n) -> vec3<f32> {\n    let light_to_frag = light.position.xyz - world_position.xyz;\n    let ligth_color_inverse_square_range = vec4<f32>(light.color.rgb, 1.0 / (light.range * light.range)) ;\n    let distance_square = dot(light_to_frag, light_to_frag);\n    let rangeAttenuation = getDistanceAttenuation(distance_square, ligth_color_inverse_square_range.w);\n\n    // Specular.\n    // Representative Point Area Lights.\n    // see http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p14-16\n    let a = roughness;\n    let centerToRay = dot(light_to_frag, R) * R - light_to_frag;\n    let closestPoint = light_to_frag + centerToRay * saturate(light.range * inverseSqrt(dot(centerToRay, centerToRay)));\n    let LspecLengthInverse = inverseSqrt(dot(closestPoint, closestPoint));\n    let normalizationFactor = a / saturate(a + (light.range * 0.5 * LspecLengthInverse));\n    let specularIntensity = normalizationFactor * normalizationFactor;\n\n    var L: vec3<f32> = closestPoint * LspecLengthInverse; // normalize() equivalent?\n    var H: vec3<f32> = normalize(L + V);\n    var NoL: f32 = saturate(dot(N, L));\n    var NoH: f32 = saturate(dot(N, H));\n    var LoH: f32 = saturate(dot(L, H));\n\n    let specular_light = specular(F0, roughness, H, NdotV, NoL, NoH, LoH, specularIntensity);\n\n    // Diffuse.\n    // Comes after specular since its NoL is used in the lighting equation.\n    L = normalize(light_to_frag);\n    H = normalize(L + V);\n    NoL = saturate(dot(N, L));\n    NoH = saturate(dot(N, H));\n    LoH = saturate(dot(L, H));\n\n    let diffuse = diffuseColor * Fd_Burley(roughness, NdotV, NoL, LoH);\n\n    // See https://google.github.io/filament/Filament.html#mjx-eqn-pointLightLuminanceEquation\n    // Lout = f(v,l) Φ / { 4 π d^2 }⟨n⋅l⟩\n    // where\n    // f(v,l) = (f_d(v,l) + f_r(v,l)) * light_color\n    // Φ is luminous power in lumens\n    // our rangeAttentuation = 1 / d^2 multiplied with an attenuation factor for smoothing at the edge of the non-physical maximum light radius\n\n    // For a point light, luminous intensity, I, in lumens per steradian is given by:\n    // I = Φ / 4 π\n    // The derivation of this can be seen here: https://google.github.io/filament/Filament.html#mjx-eqn-pointLightLuminousPower\n\n    // NOTE: light.color.rgb is premultiplied with light.intensity / 4 π (which would be the luminous intensity) on the CPU\n\n    // TODO compensate for energy loss https://google.github.io/filament/Filament.html#materialsystem/improvingthebrdfs/energylossinspecularreflectance\n\n    return ((diffuse + specular_light) * ligth_color_inverse_square_range.rgb) * (rangeAttenuation * NoL);\n}\n\n\n@fragment\nfn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {\n    if (v_in.material_index < 0) {\n        discard;\n    }\n    let material = dynamic_data.materials_data[v_in.material_index];\n\n    var output_color = material.base_color;\n    if (length(v_in.color - NULL_VEC4) > 0.) {\n        //output_color = output_color * v_in.color;\n    }\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_BASE_COLOR)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_BASE_COLOR, v_in.tex_coords_base_color);\n        output_color = output_color * t;\n    }\n    // TODO use .a for exposure compensation in HDR\n    var emissive = vec4<f32>(material.emissive_color.rgb, 1.);\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_EMISSIVE)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_EMISSIVE, v_in.tex_coords_emissive);\n        emissive = vec4<f32>(emissive.rgb * t.rgb, 1.) ;\n    }\n    // calculate non-linear roughness from linear perceptualRoughness\n    var metallic = material.metallic_factor;\n    var perceptual_roughness = material.roughness_factor;\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_METALLIC_ROUGHNESS)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_METALLIC_ROUGHNESS, v_in.tex_coords_metallic_roughness);\n        // Sampling from GLTF standard channels for now\n        metallic = metallic * t.b;\n        perceptual_roughness = perceptual_roughness * t.g;\n    }\n    let roughness = perceptualRoughnessToRoughness(perceptual_roughness);\n\n    var occlusion = 1.0;\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_OCCLUSION)) {\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_OCCLUSION, v_in.tex_coords_occlusion);\n        occlusion = t.r;\n    }\n\n    var N = normalize(v_in.world_normal);\n    var T = normalize(v_in.world_tangent.xyz - N * dot(v_in.world_tangent.xyz, N));\n    var B = cross(N, T) * v_in.world_tangent.w;\n    //if (!v_in.is_front_facing) {\n    //            N = -N;\n    //            T = -T;\n    //            B = -B;\n    //}\n    let TBN = mat3x3<f32>(T, B, N);\n    // Nt is the tangent-space normal.\n    if (has_texture(v_in.material_index, TEXTURE_TYPE_NORMAL)) {\n        var Nt = v_in.world_normal;\n        let t = get_texture_color(v_in.material_index, TEXTURE_TYPE_NORMAL, v_in.tex_coords_normal);\n        Nt = t.rgb * 2.0 - 1.0;\n        N = normalize(TBN * Nt);\n    }\n\n    if (material.alpha_mode == MATERIAL_ALPHA_BLEND_OPAQUE) {\n        output_color.a = 1.0;\n    } else if (material.alpha_mode == MATERIAL_ALPHA_BLEND_MASK) {\n        if (output_color.a >= material.alpha_cutoff) {\n            // NOTE: If rendering as masked alpha and >= the cutoff, render as fully opaque\n            output_color.a = 1.0;\n        } else {\n            // NOTE: output_color.a < material.alpha_cutoff should not is not rendered\n            // NOTE: This and any other discards mean that early-z testing cannot be done!\n            discard;\n        }\n    }\n\n    // Only valid for a perpective projection\n    let view_pos = constant_data.view[3].xyz;\n    let V = normalize(view_pos - v_in.world_position.xyz);\n\n    // Neubelt and Pettineo 2013, \"Crafting a Next-gen Material Pipeline for The Order: 1886\"\n    let NdotV = max(dot(N, V), 0.0001);\n\n    // Remapping [0,1] reflectance to F0\n    // See https://google.github.io/filament/Filament.html#materialsystem/parameterization/remapping\n    let f0 = vec3<f32>(0.04, 0.04, 0.04);\n    let specular_color = mix(f0, output_color.rgb, metallic);\n    let reflectance = max(max(specular_color.r, specular_color.g), specular_color.b);\n    let F0 = 0.16 * reflectance * reflectance * (1.0 - metallic) + output_color.rgb * metallic;\n\n    // Diffuse strength inversely related to metallicity\n    let diffuse_color = output_color.rgb * (1.0 - metallic);\n\n    let R = reflect(-V, N);\n\n    // accumulate color\n    var light_accum: vec3<f32> = vec3<f32>(0.0);\n\n    var i = 0u;\n    loop {\n        let light = dynamic_data.lights_data[i];\n        if (dynamic_data.lights_data[i].light_type == 0u) {\n            break;\n        }\n        var shadow: f32 = 1.0;\n        //if ((mesh.flags & MESH_FLAGS_SHADOW_RECEIVER_BIT) != 0u\n        //        && (light.flags & POINT_LIGHT_FLAGS_SHADOWS_ENABLED_BIT) != 0u) {\n        //    shadow = fetch_point_shadow(light_id, in.world_position, in.world_normal);\n        //}\n        let light_contrib = point_light(v_in.world_position.xyz, light, roughness, NdotV, N, V, R, F0, diffuse_color);\n        light_accum = light_accum + light_contrib * shadow;\n\n        i = i + 1u;\n    }\n\n    //TODO: Directional lights\n\n\n    let diffuse_ambient = EnvBRDFApprox(diffuse_color, 1.0, NdotV);\n    let specular_ambient = EnvBRDFApprox(F0, perceptual_roughness, NdotV);\n\n    output_color = vec4<f32>(\n        light_accum + (diffuse_ambient + specular_ambient) * AMBIENT_COLOR.rgb * occlusion + emissive.rgb * output_color.a,\n        output_color.a\n    );\n\n    // tone_mapping\n    output_color = vec4<f32>(reinhard_luminance(output_color.rgb), output_color.a);\n    // Gamma correction.\n    // Not needed with sRGB buffer\n    output_color = vec4<f32>(pow(output_color.rgb, vec3<f32>(1.0 / 2.2)), output_color.a);\n\n    return output_color;\n}\n"}
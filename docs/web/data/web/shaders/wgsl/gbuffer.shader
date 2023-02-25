{"spirv_code":[],"wgsl_code":"\nfn quantize_unorm(v: f32, n: u32) -> u32 {\n    let scale = f32((1 << n) - 1);\n    return u32(0.5 + (v * scale));\n}\nfn quantize_snorm(v: f32, n: u32) -> u32 {\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if v < 0. {\n        return (u32(-v * scale) & c) | (1u << (n - 1u));\n    } else {\n        return u32(v * scale) & c;\n    }\n}\n\nfn decode_unorm(i: u32, n: u32) -> f32 {    \n    let scale = f32((1 << n) - 1);\n    if (i == 0u) {\n        return 0.;\n    } else if (i == u32(scale)) {\n        return 1.;\n    } else {\n        return (f32(i) - 0.5) / scale;\n    }\n}\n\nfn decode_snorm(i: u32, n: u32) -> f32 {\n    let s = i >> (n - 1u);\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if s > 0u {\n        let r = f32(i & c) / scale;\n        return -r;\n    } else {\n        return f32(i & c) / scale;\n    }\n}\n\n\nfn decode_uv(v: u32) -> vec2<f32> {\n    return unpack2x16float(v);\n}\nfn decode_as_vec3(v: u32) -> vec3<f32> {\n    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_unorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {\n    let r = quantize_unorm(value.x, 8u) << 24u;\n    let g = quantize_unorm(value.y, 8u) << 16u;\n    let b = quantize_unorm(value.z, 8u) << 8u;\n    let a = quantize_unorm(value.w, 8u);\n    return (r | g | b | a);\n}\nfn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_snorm((v >> 24u) & 255u, 8u);\n    let g = decode_snorm((v >> 16u) & 255u, 8u);\n    let b = decode_snorm((v >> 8u) & 255u, 8u);\n    let a = decode_snorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\nfn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_unorm((v >> 24u) & 255u, 8u);\n    let g = decode_unorm((v >> 16u) & 255u, 8u);\n    let b = decode_unorm((v >> 8u) & 255u, 8u);\n    let a = decode_unorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\n\n// 0-1 from 0-255\nfn linear_from_srgb(srgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = srgb < vec3<f32>(10.31475);\n    let lower = srgb / vec3<f32>(3294.6);\n    let higher = pow((srgb + vec3<f32>(14.025)) / vec3<f32>(269.025), vec3<f32>(2.4));\n    return select(higher, lower, cutoff);\n}\n\n// [u8; 4] SRGB as u32 -> [r, g, b, a]\nfn unpack_color(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(color & 255u),\n        f32((color >> 8u) & 255u),\n        f32((color >> 16u) & 255u),\n        f32((color >> 24u) & 255u),\n    );\n}\n\n// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.\nfn hash( x: u32 ) -> u32 {\n    var v = x;\n    v += ( v << 10u );\n    v ^= ( v >>  6u );\n    v += ( v <<  3u );\n    v ^= ( v >> 11u );\n    v += ( v << 15u );\n    return v;\n}\n\n\nfn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) \n{\n    let c = *ptr_a;\n    *ptr_a = *ptr_b;\n    *ptr_b = c;\n}\nconst MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;\nconst MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nconst TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nconst TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nconst TEXTURE_TYPE_NORMAL: u32 = 2u;\nconst TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nconst TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nconst TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nconst TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nconst TEXTURE_TYPE_COUNT: u32 = 8u;\n\nconst MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nconst MATERIAL_ALPHA_BLEND_MASK = 1u;\nconst MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nconst MESH_FLAGS_NONE: u32 = 0u;\nconst MESH_FLAGS_VISIBLE: u32 = 1u;\nconst MESH_FLAGS_OPAQUE: u32 = 2u; // 1 << 1\nconst MESH_FLAGS_TRANSPARENT: u32 = 4u;  // 1 << 2\nconst MESH_FLAGS_WIREFRAME: u32 = 8u; // 1 << 3\nconst MESH_FLAGS_DEBUG: u32 = 16u; // 1 << 4\nconst MESH_FLAGS_UI: u32 = 32u; // 1 << 5\n\nconst CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nconst CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_SPHERE: u32 = 4u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 8u;\n\nconst MAX_FLOAT: f32 = 3.402823466e+38;\n\nconst RAY_STEP_FLAGS_NONE: u32 = 0u;\nconst RAY_STEP_FLAGS_COMPUTE_RAY: u32 = 1u;\nconst RAY_STEP_FLAGS_TLAS: u32 = 2u; // 1 << 1\nconst RAY_STEP_FLAGS_BLAS: u32 = 4u; // 1 << 2\nconst RAY_STEP_FLAGS_MESHLET: u32 = 8u;  // 1 << 3\nconst RAY_STEP_FLAGS_BOUNCE: u32 = 16u; // 1 << 4\n\nstruct RayPayload {\n    origin: vec3<f32>,\n    pixel_x: u32,\n    direction: vec3<f32>,\n    pixel_y: u32,\n};\n\nstruct RayJob {\n    index: u32,\n    step: u32,\n}\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    inverse_view_proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    cam_fov: f32,\n    flags: u32,\n};\n\nstruct Vertex {\n    @location(0) position_and_color_offset: u32,\n    @location(1) normal_offset: i32,\n    @location(2) tangent_offset: i32,\n    @location(3) mesh_index: u32,\n    @location(4) uvs_offset: vec4<i32>,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_vertex: u32,\n    base_instance: u32,\n};\n\nstruct DrawIndexedCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct Mesh {\n    vertex_offset: u32,\n    indices_offset: u32,\n    material_index: i32,\n    bhv_index: u32,\n    position: vec3<f32>,\n    meshlets_offset: u32,\n    scale: vec3<f32>,\n    meshlets_count: u32,\n    orientation: vec4<f32>,\n};\n\nstruct ConeCulling {\n    center: vec3<f32>,\n    cone_axis_cutoff: u32,\n};\n\nstruct Meshlet {\n    @location(5) mesh_index: u32,\n    @location(6) indices_offset: u32,\n    @location(7) indices_count: u32,\n    @location(8) bhv_index: u32,\n};\n\nstruct BHVNode {\n    min: vec3<f32>,\n    miss: i32,\n    max: vec3<f32>,\n    reference: i32, //-1 or mesh_index or meshlet_index or triangle_index\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct Material {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<Material>,\n};\n\nstruct DrawCommands {\n    data: array<DrawCommand>,\n};\n\nstruct DrawIndexedCommands {\n    data: array<DrawIndexedCommand>,\n};\n\nstruct Meshes {\n    data: array<Mesh>,\n};\n\nstruct Meshlets {\n    data: array<Meshlet>,\n};\n\nstruct Indices {\n    data: array<u32>,\n};\n\nstruct Vertices {\n    data: array<Vertex>,\n};\n\nstruct Matrices {\n    data: array<mat4x4<f32>>,\n};\n\nstruct Positions {\n    data: array<u32>,\n};\n\nstruct Colors {\n    data: array<u32>,\n};\n\nstruct Normals {\n    data: array<u32>,\n};\n\nstruct Tangents {\n    data: array<vec4<f32>>,\n};\n\nstruct UVs {\n    data: array<u32>,\n};\n\nstruct MeshletsCulling {\n    data: array<ConeCulling>,\n};\n\nstruct BHV {\n    data: array<BHVNode>,\n};\n\nstruct MeshFlags {\n    data: array<u32>,\n};\n\n\nstruct Ray {\n    origin: vec3<f32>,\n    t_min: f32,\n    direction: vec3<f32>,\n    t_max: f32,\n}\n\nstruct Rays {\n    data: array<Ray>,\n};\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) @interpolate(flat) mesh_and_meshlet_ids: vec2<u32>,\n    @location(1) world_pos: vec4<f32>,\n    @location(2) color: vec4<f32>,\n    @location(3) normal: vec3<f32>,\n    @location(4) uv_0: vec2<f32>,\n    @location(5) uv_1: vec2<f32>,\n    @location(6) uv_2: vec2<f32>,\n    @location(7) uv_3: vec2<f32>,\n};\n\nstruct FragmentOutput {\n    @location(0) gbuffer_1: vec4<f32>,  //color        \n    @location(1) gbuffer_2: vec4<f32>,  //normal       \n    @location(2) gbuffer_3: vec4<f32>,  //meshlet_id   \n    @location(3) gbuffer_4: vec4<f32>,  //uv_0         \n    @location(4) gbuffer_5: vec4<f32>,  //uv_1         \n    @location(5) gbuffer_6: vec4<f32>,  //uv_2         \n    @location(6) gbuffer_7: vec4<f32>,  //uv_3         \n};\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read> positions: Positions;\n@group(0) @binding(2)\nvar<storage, read> colors: Colors;\n@group(0) @binding(3)\nvar<storage, read> normals: Normals;\n@group(0) @binding(4)\nvar<storage, read> uvs: UVs;\n\n@group(1) @binding(0)\nvar<storage, read> meshes: Meshes;\n@group(1) @binding(1)\nvar<storage, read> materials: Materials;\n@group(1) @binding(2)\nvar<storage, read> textures: Textures;\n@group(1) @binding(3)\nvar<storage, read> meshlets: Meshlets;\n@group(1) @binding(4)\nvar<storage, read> bhv: BHV;\n\n\nfn extract_scale(m: mat4x4<f32>) -> vec3<f32> \n{\n    let s = mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz);\n    let sx = length(s[0]);\n    let sy = length(s[1]);\n    let det = determinant(s);\n    var sz = length(s[2]);\n    if (det < 0.) \n    {\n        sz = -sz;\n    }\n    return vec3<f32>(sx, sy, sz);\n}\n\nfn matrix_row(m: mat4x4<f32>, row: u32) -> vec4<f32> \n{\n    if (row == 1u) {\n        return vec4<f32>(m[0].y, m[1].y, m[2].y, m[3].y);\n    } else if (row == 2u) {\n        return vec4<f32>(m[0].z, m[1].z, m[2].z, m[3].z);\n    } else if (row == 3u) {\n        return vec4<f32>(m[0].w, m[1].w, m[2].w, m[3].w);\n    } else {        \n        return vec4<f32>(m[0].x, m[1].x, m[2].x, m[3].x);\n    }\n}\n\nfn normalize_plane(plane: vec4<f32>) -> vec4<f32> \n{\n    return (plane / length(plane.xyz));\n}\n\nfn unproject(ncd_pos: vec2<f32>, depth: f32) -> vec3<f32> \n{    \n    var world_pos = constant_data.inverse_view_proj * vec4<f32>(ncd_pos, depth, 1. );\n    world_pos /= world_pos.w;\n    return world_pos.xyz;\n}\n\nfn rotate_vector(v: vec3<f32>, orientation: vec4<f32>) -> vec3<f32> \n{\n    return v + 2. * cross(orientation.xyz, cross(orientation.xyz, v) + orientation.w * v);\n}\n\nfn transform_vector(v: vec3<f32>, position: vec3<f32>, orientation: vec4<f32>, scale: vec3<f32>) -> vec3<f32> \n{\n    return rotate_vector(v, orientation) * scale + position;\n}\n@group(2) @binding(0)\nvar default_sampler: sampler;\n\n@group(2) @binding(1)\nvar texture_1: texture_2d_array<f32>;\n@group(2) @binding(2)\nvar texture_2: texture_2d_array<f32>;\n@group(2) @binding(3)\nvar texture_3: texture_2d_array<f32>;\n@group(2) @binding(4)\nvar texture_4: texture_2d_array<f32>;\n@group(2) @binding(5)\nvar texture_5: texture_2d_array<f32>;\n@group(2) @binding(6)\nvar texture_6: texture_2d_array<f32>;\n@group(2) @binding(7)\nvar texture_7: texture_2d_array<f32>;\n\n\nfn sample_texture(tex_coords_and_texture_index: vec3<f32>) -> vec4<f32> {\n    let texture_data_index = i32(tex_coords_and_texture_index.z);\n    var v = vec4<f32>(0.);\n    var tex_coords = vec3<f32>(0.0, 0.0, 0.0);\n    if (texture_data_index < 0) {\n        return v;\n    }\n    let texture = &textures.data[texture_data_index];\n    let atlas_index = (*texture).texture_index;\n    let layer_index = i32((*texture).layer_index);\n\n    tex_coords.x = ((*texture).area.x + tex_coords_and_texture_index.x * (*texture).area.z) / (*texture).total_width;\n    tex_coords.y = ((*texture).area.y + tex_coords_and_texture_index.y * (*texture).area.w) / (*texture).total_height;\n    tex_coords.z = f32(layer_index);\n\n    switch (atlas_index) {\n        case 0u: { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 1u: { v = textureSampleLevel(texture_2, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 2u: { v = textureSampleLevel(texture_3, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 3u: { v = textureSampleLevel(texture_4, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 4u: { v = textureSampleLevel(texture_5, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 5u: { v = textureSampleLevel(texture_6, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 6u: { v = textureSampleLevel(texture_7, default_sampler, tex_coords.xy, layer_index, 0.); }\n        default { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }\n    };\n    return v;\n}\nfn has_texture(material_index: u32, texture_type: u32) -> bool {\n    if (materials.data[material_index].textures_indices[texture_type] >= 0) {\n        return true;\n    }\n    return false;\n}\n\nfn material_texture_index(material_index: u32, texture_type: u32) -> i32 {\n    let material = &materials.data[material_index];\n    let texture_index = (*material).textures_indices[texture_type];\n    if (texture_index < 0) {\n        return 0;\n    }\n    return texture_index;\n}\n\nfn material_texture_coord_set(material_index: u32, texture_type: u32) -> u32 {\n    let material = &materials.data[material_index];\n    return (*material).textures_coord_set[texture_type];\n}\n\nfn get_uv(uv_set: vec4<u32>, texture_index: u32, coords_set: u32) -> vec3<f32> {\n    var uv = vec2<f32>(0., 0.);\n    switch (coords_set) {\n        case 1u: { uv = unpack2x16float(uv_set.y); }\n        case 2u: { uv = unpack2x16float(uv_set.z); }\n        case 3u: { uv = unpack2x16float(uv_set.w); }\n        default { uv = unpack2x16float(uv_set.x); }\n    }\n    return vec3<f32>(uv, f32(texture_index));\n}\n\nfn compute_uvs(material_index: u32, texture_type: u32, uv_set: vec4<u32>) -> vec3<f32> {\n    let texture_id = material_texture_index(material_index, texture_type);\n    let coords_set = material_texture_coord_set(material_index, texture_type);  \n    let uv = get_uv(uv_set, u32(texture_id), coords_set);\n    return uv;\n}\n\nfn sample_material_texture(material_index: u32, texture_type: u32, uv_set: vec4<u32>) -> vec4<f32> {\n    let uv = compute_uvs(material_index, texture_type, uv_set);\n    return sample_texture(uv);\n}\n\n\n@vertex\nfn vs_main(\n    @builtin(vertex_index) vertex_index: u32,\n    @builtin(instance_index) meshlet_id: u32,\n    v_in: Vertex,\n) -> VertexOutput {\n    let mvp = constant_data.proj * constant_data.view;\n\n    let mesh_id = u32(meshlets.data[meshlet_id].mesh_index);\n    let mesh = &meshes.data[mesh_id];\n    let aabb = &bhv.data[(*mesh).bhv_index];\n\n    let aabb_size = abs((*aabb).max - (*aabb).min);\n    \n    let p = (*aabb).min + decode_as_vec3(positions.data[v_in.position_and_color_offset]) * aabb_size;\n    let world_position = vec4<f32>(transform_vector(p, (*mesh).position, (*mesh).orientation, (*mesh).scale), 1.0);\n    let color = unpack_unorm_to_4_f32(colors.data[v_in.position_and_color_offset]);\n    \n    var vertex_out: VertexOutput;\n    vertex_out.clip_position = mvp * world_position;\n    vertex_out.mesh_and_meshlet_ids = vec2<u32>(mesh_id, meshlet_id);\n    vertex_out.world_pos = world_position;\n    vertex_out.color = color;\n    vertex_out.normal = decode_as_vec3(normals.data[v_in.normal_offset]); \n    vertex_out.uv_0 = unpack2x16float(uvs.data[v_in.uvs_offset.x]);\n    vertex_out.uv_1 = unpack2x16float(uvs.data[v_in.uvs_offset.y]);\n    vertex_out.uv_2 = unpack2x16float(uvs.data[v_in.uvs_offset.z]);\n    vertex_out.uv_3 = unpack2x16float(uvs.data[v_in.uvs_offset.w]);\n\n    return vertex_out;\n}\n\n@fragment\nfn fs_main(\n    v_in: VertexOutput,\n) -> FragmentOutput {    \n    var fragment_out: FragmentOutput;\n\n    let mesh_id = u32(v_in.mesh_and_meshlet_ids.x);\n    let mesh = &meshes.data[mesh_id];\n    let material_id = u32((*mesh).material_index);\n    let uv_set = vec4<u32>(\n        pack2x16float(v_in.uv_0),\n        pack2x16float(v_in.uv_1),\n        pack2x16float(v_in.uv_2),\n        pack2x16float(v_in.uv_3)\n    );\n\n    fragment_out.gbuffer_1 = v_in.color;\n    fragment_out.gbuffer_2 = unpack4x8unorm(pack2x16float(pack_normal(v_in.normal.xyz)));\n    fragment_out.gbuffer_3 = unpack4x8unorm(v_in.mesh_and_meshlet_ids.y + 1u);\n    fragment_out.gbuffer_4 = unpack4x8unorm(pack2x16float(v_in.uv_0));\n    fragment_out.gbuffer_5 = unpack4x8unorm(pack2x16float(v_in.uv_1));\n    fragment_out.gbuffer_6 = unpack4x8unorm(pack2x16float(v_in.uv_2));\n    fragment_out.gbuffer_7 = unpack4x8unorm(pack2x16float(v_in.uv_3));\n    \n    return fragment_out;\n}\n"}
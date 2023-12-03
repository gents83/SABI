{"spirv_code":[],"wgsl_code":"const MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;\nconst MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nconst TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nconst TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nconst TEXTURE_TYPE_NORMAL: u32 = 2u;\nconst TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nconst TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nconst TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nconst TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nconst TEXTURE_TYPE_COUNT: u32 = 8u;\n\nconst MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nconst MATERIAL_ALPHA_BLEND_MASK = 1u;\nconst MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nconst MESH_FLAGS_NONE: u32 = 0u;\nconst MESH_FLAGS_VISIBLE: u32 = 1u;\nconst MESH_FLAGS_OPAQUE: u32 = 2u; // 1 << 1\nconst MESH_FLAGS_TRANSPARENT: u32 = 4u;  // 1 << 2\nconst MESH_FLAGS_WIREFRAME: u32 = 8u; // 1 << 3\nconst MESH_FLAGS_DEBUG: u32 = 16u; // 1 << 4\nconst MESH_FLAGS_UI: u32 = 32u; // 1 << 5\n\nconst CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nconst CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_SPHERE: u32 = 4u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 8u;\n\nconst PI: f32 = 3.141592653589793238462643;\nconst MAX_FLOAT: f32 = 3.402823466e+38;\n\nconst VERTEX_ATTRIBUTE_HAS_POSITION: u32 = 0u;\nconst VERTEX_ATTRIBUTE_HAS_COLOR: u32 = 1u;\nconst VERTEX_ATTRIBUTE_HAS_NORMAL: u32 = 2u; // 1 << 1\nconst VERTEX_ATTRIBUTE_HAS_UV1: u32 = 4u; // 1 << 2\nconst VERTEX_ATTRIBUTE_HAS_UV2: u32 = 8u;  // 1 << 3\nconst VERTEX_ATTRIBUTE_HAS_UV3: u32 = 16u; // 1 << 4\nconst VERTEX_ATTRIBUTE_HAS_UV4: u32 = 32u; // 1 << 5\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    inverse_view_proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    frame_index: u32,\n    flags: u32,\n};\n\nstruct RuntimeVertexData {\n    @location(0) world_pos: vec3<f32>,\n    @location(1) @interpolate(flat) mesh_index: u32,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_vertex: u32,\n    base_instance: u32,\n};\n\nstruct DrawIndexedCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct Mesh {\n    vertices_position_offset: u32,\n    vertices_attribute_offset: u32,\n    vertices_attribute_layout: u32,\n    material_index: i32,\n    orientation: vec4<f32>,\n    position: vec3<f32>,\n    meshlets_offset: u32,\n    scale: vec3<f32>,\n    blas_index: u32,\n};\n\nstruct ConeCulling {\n    center: vec3<f32>,\n    cone_axis_cutoff: u32,\n};\n\nstruct Meshlet {\n    @location(5) mesh_index: u32,\n    @location(6) indices_offset: u32,\n    @location(7) indices_count: u32,\n    @location(8) blas_index: u32,\n};\n\nstruct BHVNode {\n    min: vec3<f32>,\n    miss: i32,\n    max: vec3<f32>,\n    reference: i32, //-1 or mesh_index or meshlet_index or triangle_index\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct Material {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<Material>,\n};\n\nstruct DrawCommands {\n    data: array<DrawCommand>,\n};\n\nstruct DrawIndexedCommands {\n    data: array<DrawIndexedCommand>,\n};\n\nstruct Meshes {\n    data: array<Mesh>,\n};\n\nstruct Meshlets {\n    data: array<Meshlet>,\n};\n\nstruct Indices {\n    data: array<u32>,\n};\n\nstruct RuntimeVertices {\n    data: array<RuntimeVertexData>,\n};\n\nstruct VerticesPositions {\n    data: array<u32>,\n};\n\nstruct VerticesAttributes {\n    data: array<u32>,\n};\n\nstruct MeshletsCulling {\n    data: array<ConeCulling>,\n};\n\nstruct Matrices {\n    data: array<mat4x4<f32>>,\n};\n\nstruct BHV {\n    data: array<BHVNode>,\n};\n\nstruct MeshFlags {\n    data: array<u32>,\n};\n\n\nstruct Ray {\n    origin: vec3<f32>,\n    t_min: f32,\n    direction: vec3<f32>,\n    t_max: f32,\n};\n\nstruct Rays {\n    data: array<Ray>,\n};\n\nstruct RayJob {\n    index: u32,\n    step: u32,\n}\n\nstruct PixelData {\n    world_pos: vec3<f32>,\n    depth: f32,\n    normal: vec3<f32>,\n    material_id: u32,\n    color: vec4<f32>,\n    uv_set: array<vec2<f32>, 4>,\n};\nfn quantize_unorm(v: f32, n: u32) -> u32 {\n    let scale = f32((1 << n) - 1);\n    return u32(0.5 + (v * scale));\n}\nfn quantize_snorm(v: f32, n: u32) -> u32 {\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if v < 0. {\n        return (u32(-v * scale) & c) | (1u << (n - 1u));\n    } else {\n        return u32(v * scale) & c;\n    }\n}\n\nfn decode_unorm(i: u32, n: u32) -> f32 {    \n    let scale = f32((1 << n) - 1);\n    if (i == 0u) {\n        return 0.;\n    } else if (i == u32(scale)) {\n        return 1.;\n    } else {\n        return (f32(i) - 0.5) / scale;\n    }\n}\n\nfn decode_snorm(i: u32, n: u32) -> f32 {\n    let s = i >> (n - 1u);\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if s > 0u {\n        let r = f32(i & c) / scale;\n        return -r;\n    } else {\n        return f32(i & c) / scale;\n    }\n}\n\nfn unpack_unorm_to_3_f32(v: u32) -> vec3<f32> {\n    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_unorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn unpack_snorm_to_3_f32(v: u32) -> vec3<f32> {\n    let vx = decode_snorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_snorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_snorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {\n    let r = quantize_unorm(value.x, 8u) << 24u;\n    let g = quantize_unorm(value.y, 8u) << 16u;\n    let b = quantize_unorm(value.z, 8u) << 8u;\n    let a = quantize_unorm(value.w, 8u);\n    return (r | g | b | a);\n}\nfn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_snorm((v >> 24u) & 255u, 8u);\n    let g = decode_snorm((v >> 16u) & 255u, 8u);\n    let b = decode_snorm((v >> 8u) & 255u, 8u);\n    let a = decode_snorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\nfn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_unorm((v >> 24u) & 255u, 8u);\n    let g = decode_unorm((v >> 16u) & 255u, 8u);\n    let b = decode_unorm((v >> 8u) & 255u, 8u);\n    let a = decode_unorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\n\n// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.\nfn hash( x: u32 ) -> u32 {\n    var v = x;\n    v += ( v << 10u );\n    v ^= ( v >>  6u );\n    v += ( v <<  3u );\n    v ^= ( v >> 11u );\n    v += ( v << 15u );\n    return v;\n}\n\n// This is PCG\nfn get_random_numbers(seed: vec2<u32>) -> vec2<u32> {\n    var new_seed = seed;\n    new_seed = 1664525u * new_seed + 1013904223u;\n    new_seed.x += 1664525u * new_seed.y;\n    new_seed.y += 1664525u * new_seed.x;\n    new_seed.x = new_seed.x ^ (new_seed.x >> 16u);\n    new_seed.y = new_seed.y ^ (new_seed.y >> 16u);\n    new_seed.x += 1664525u * new_seed.y;\n    new_seed.y += 1664525u * new_seed.x;\n    new_seed.x = new_seed.x ^ (new_seed.x >> 16u);\n    new_seed.y = new_seed.y ^ (new_seed.y >> 16u);\n    return new_seed;\n}\n\nfn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) \n{\n    let c = *ptr_a;\n    *ptr_a = *ptr_b;\n    *ptr_b = c;\n}\n\nfn has_vertex_attribute(vertex_attribute_layout: u32, attribute_to_check: u32) -> bool {\n    return bool(vertex_attribute_layout & attribute_to_check);\n}\nfn vertex_attribute_offset(vertex_attribute_layout: u32, attribute_to_check: u32) -> i32 \n{\n    if(has_vertex_attribute(vertex_attribute_layout, attribute_to_check)) {\n        let mask = vertex_attribute_layout & (~attribute_to_check & (attribute_to_check - 1u));\n        return i32(countOneBits(mask));\n    }\n    return -1;\n}\nfn vertex_layout_stride(vertex_attribute_layout: u32) -> u32 \n{\n    return countOneBits(vertex_attribute_layout);\n}\n\nstruct CullingData {\n    view: mat4x4<f32>,\n    mesh_flags: u32,\n    _padding1: u32,\n    _padding2: u32,\n    _padding3: u32,\n};\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<uniform> culling_data: CullingData;\n@group(0) @binding(2)\nvar<storage, read> meshlets: Meshlets;\n@group(0) @binding(3)\nvar<storage, read> meshlets_culling: MeshletsCulling;\n@group(0) @binding(4)\nvar<storage, read> meshes: Meshes;\n@group(0) @binding(5)\nvar<storage, read> bhv: BHV;\n@group(0) @binding(6)\nvar<storage, read> meshes_flags: MeshFlags;\n\n@group(1) @binding(0)\nvar<storage, read_write> count: atomic<u32>;\n@group(1) @binding(1)\nvar<storage, read_write> commands: DrawIndexedCommands;\n@group(1) @binding(2)\nvar<storage, read_write> culling_result: array<atomic<u32>>;\n\n\nfn extract_scale(m: mat4x4<f32>) -> vec3<f32> \n{\n    let s = mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz);\n    let sx = length(s[0]);\n    let sy = length(s[1]);\n    let det = determinant(s);\n    var sz = length(s[2]);\n    if (det < 0.) \n    {\n        sz = -sz;\n    }\n    return vec3<f32>(sx, sy, sz);\n}\n\nfn matrix_row(m: mat4x4<f32>, row: u32) -> vec4<f32> \n{\n    if (row == 1u) {\n        return vec4<f32>(m[0].y, m[1].y, m[2].y, m[3].y);\n    } else if (row == 2u) {\n        return vec4<f32>(m[0].z, m[1].z, m[2].z, m[3].z);\n    } else if (row == 3u) {\n        return vec4<f32>(m[0].w, m[1].w, m[2].w, m[3].w);\n    } else {        \n        return vec4<f32>(m[0].x, m[1].x, m[2].x, m[3].x);\n    }\n}\n\nfn normalize_plane(plane: vec4<f32>) -> vec4<f32> \n{\n    return (plane / length(plane.xyz));\n}\n\nfn rotate_vector(v: vec3<f32>, orientation: vec4<f32>) -> vec3<f32> \n{\n    return v + 2. * cross(orientation.xyz, cross(orientation.xyz, v) + orientation.w * v);\n}\n\nfn transform_vector(v: vec3<f32>, position: vec3<f32>, orientation: vec4<f32>, scale: vec3<f32>) -> vec3<f32> \n{\n    return rotate_vector(v, orientation) * scale + position;\n}\n\n\n//ScreenSpace Frustum Culling\nfn is_sphere_inside_frustum(center: vec3<f32>, radius: f32, frustum: array<vec4<f32>, 4>) -> bool {\n    var visible: bool = true;    \n    var f = frustum;\n    for(var i = 0; i < 4; i = i + 1) {  \n        visible = visible && !(dot(f[i].xyz, center) + f[i].w + radius <= 0.);\n    }   \n    return visible;\n}\n\nfn is_box_inside_frustum(min: vec3<f32>, max: vec3<f32>, frustum: array<vec4<f32>, 4>) -> bool {\n    var visible: bool = false;    \n    var points: array<vec3<f32>, 8>;\n    points[0] = min;\n    points[1] = max;\n    points[2] = vec3<f32>(min.x, min.y, max.z);\n    points[3] = vec3<f32>(min.x, max.y, max.z);\n    points[4] = vec3<f32>(min.x, max.y, min.z);\n    points[5] = vec3<f32>(max.x, min.y, min.z);\n    points[6] = vec3<f32>(max.x, max.y, min.z);\n    points[7] = vec3<f32>(max.x, min.y, max.z);\n      \n    var f = frustum;\n    for(var i = 0; !visible && i < 4; i = i + 1) {  \n        for(var p = 0; !visible && p < 8; p = p + 1) {        \n            visible = visible || !(dot(f[i].xyz, points[p]) + f[i].w <= 0.);\n        }\n    }   \n    return visible;\n}\n\nfn is_cone_visible(center: vec3<f32>, cone_axis: vec3<f32>, cone_cutoff: f32, radius: f32) -> bool {\n    let direction = center - culling_data.view[3].xyz;\n    return dot(normalize(direction), cone_axis) < (cone_cutoff * length(direction) + radius);\n}\n\n\n@compute\n@workgroup_size(32, 1, 1)\nfn main(\n    @builtin(local_invocation_id) local_invocation_id: vec3<u32>, \n    @builtin(local_invocation_index) local_invocation_index: u32, \n    @builtin(global_invocation_id) global_invocation_id: vec3<u32>, \n    @builtin(workgroup_id) workgroup_id: vec3<u32>\n) {\n    let total = arrayLength(&meshlets.data);\n    let meshlet_id = global_invocation_id.x;\n    if (meshlet_id >= total) {\n        return;\n    }\n    let command = &commands.data[meshlet_id];\n    (*command).vertex_count = 0u;\n    (*command).instance_count = 0u;\n    (*command).base_index = 0u;\n    (*command).vertex_offset = 0;\n    (*command).base_instance = 0u;\n\n    let meshlet = &meshlets.data[meshlet_id];\n    let mesh_id = (*meshlet).mesh_index;\n    \n    if (meshes_flags.data[mesh_id] != culling_data.mesh_flags) {\n        return;        \n    }\n\n    let mesh = &meshes.data[mesh_id];\n    let bb_id = (*mesh).blas_index + (*meshlet).blas_index;\n    let bb = &bhv.data[bb_id];\n    let max = transform_vector((*bb).max, (*mesh).position, (*mesh).orientation, (*mesh).scale);\n    let min = transform_vector((*bb).min, (*mesh).position, (*mesh).orientation, (*mesh).scale);\n    let d = (max-min) * 0.5;\n    let center = min + d;\n    let radius = length(d);\n\n    let mvp = constant_data.proj * culling_data.view;\n    let row0 = matrix_row(mvp, 0u);\n    let row1 = matrix_row(mvp, 1u);\n    let row3 = matrix_row(mvp, 3u);\n\n    var frustum: array<vec4<f32>, 4>;\n    frustum[0] = normalize_plane(row3 + row0);\n    frustum[1] = normalize_plane(row3 - row0);\n    frustum[2] = normalize_plane(row3 + row1);\n    frustum[3] = normalize_plane(row3 - row1);\n\n\n    if !is_sphere_inside_frustum(center, radius, frustum) {\n        return;\n    }\n    \n    if !is_box_inside_frustum(min, max, frustum) {\n        return;\n    }\n\n    let cone_culling = &meshlets_culling.data[meshlet_id];\n    let cone_axis_cutoff = unpack4x8snorm((*cone_culling).cone_axis_cutoff);\n    let cone_axis = rotate_vector(cone_axis_cutoff.xyz, (*mesh).orientation);    \n    if (is_cone_visible((*cone_culling).center, cone_axis, cone_axis_cutoff.w, radius))\n    {\n        atomicAdd(&count, 1u);\n        let draw_group_index = workgroup_id.x;\n        atomicOr(&culling_result[draw_group_index], 1u << local_invocation_id.x);\n    }\n}\n"}
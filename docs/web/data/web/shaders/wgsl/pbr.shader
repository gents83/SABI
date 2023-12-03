{"spirv_code":[],"wgsl_code":"const MAX_TEXTURE_ATLAS_COUNT: u32 = 8u;\nconst MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nconst TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nconst TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nconst TEXTURE_TYPE_NORMAL: u32 = 2u;\nconst TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nconst TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nconst TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nconst TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nconst TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nconst TEXTURE_TYPE_COUNT: u32 = 8u;\n\nconst MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nconst MATERIAL_ALPHA_BLEND_MASK = 1u;\nconst MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nconst MESH_FLAGS_NONE: u32 = 0u;\nconst MESH_FLAGS_VISIBLE: u32 = 1u;\nconst MESH_FLAGS_OPAQUE: u32 = 2u; // 1 << 1\nconst MESH_FLAGS_TRANSPARENT: u32 = 4u;  // 1 << 2\nconst MESH_FLAGS_WIREFRAME: u32 = 8u; // 1 << 3\nconst MESH_FLAGS_DEBUG: u32 = 16u; // 1 << 4\nconst MESH_FLAGS_UI: u32 = 32u; // 1 << 5\n\nconst CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nconst CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_SPHERE: u32 = 4u;\nconst CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 8u;\n\nconst PI: f32 = 3.141592653589793;\nconst MAX_FLOAT: f32 = 3.402823466e+38;\n\nconst VERTEX_ATTRIBUTE_HAS_POSITION: u32 = 0u;\nconst VERTEX_ATTRIBUTE_HAS_COLOR: u32 = 1u;\nconst VERTEX_ATTRIBUTE_HAS_NORMAL: u32 = 2u; // 1 << 1\nconst VERTEX_ATTRIBUTE_HAS_UV1: u32 = 4u; // 1 << 2\nconst VERTEX_ATTRIBUTE_HAS_UV2: u32 = 8u;  // 1 << 3\nconst VERTEX_ATTRIBUTE_HAS_UV3: u32 = 16u; // 1 << 4\nconst VERTEX_ATTRIBUTE_HAS_UV4: u32 = 32u; // 1 << 5\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    inverse_view_proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    cam_fov: f32,\n    flags: u32,\n};\n\nstruct RuntimeVertexData {\n    @location(0) world_pos: vec3<f32>,\n    @location(1) @interpolate(flat) mesh_index: u32,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_vertex: u32,\n    base_instance: u32,\n};\n\nstruct DrawIndexedCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct Mesh {\n    vertices_position_offset: u32,\n    vertices_attribute_offset: u32,\n    vertices_attribute_layout: u32,\n    material_index: i32,\n    orientation: vec4<f32>,\n    position: vec3<f32>,\n    meshlets_offset: u32,\n    scale: vec3<f32>,\n    blas_index: u32,\n};\n\nstruct ConeCulling {\n    center: vec3<f32>,\n    cone_axis_cutoff: u32,\n};\n\nstruct Meshlet {\n    @location(5) mesh_index: u32,\n    @location(6) indices_offset: u32,\n    @location(7) indices_count: u32,\n    @location(8) blas_index: u32,\n};\n\nstruct BHVNode {\n    min: vec3<f32>,\n    miss: i32,\n    max: vec3<f32>,\n    reference: i32, //-1 or mesh_index or meshlet_index or triangle_index\n};\n\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct Material {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<Material>,\n};\n\nstruct DrawCommands {\n    data: array<DrawCommand>,\n};\n\nstruct DrawIndexedCommands {\n    data: array<DrawIndexedCommand>,\n};\n\nstruct Meshes {\n    data: array<Mesh>,\n};\n\nstruct Meshlets {\n    data: array<Meshlet>,\n};\n\nstruct Indices {\n    data: array<u32>,\n};\n\nstruct RuntimeVertices {\n    data: array<RuntimeVertexData>,\n};\n\nstruct VerticesPositions {\n    data: array<u32>,\n};\n\nstruct VerticesAttributes {\n    data: array<u32>,\n};\n\nstruct MeshletsCulling {\n    data: array<ConeCulling>,\n};\n\nstruct Matrices {\n    data: array<mat4x4<f32>>,\n};\n\nstruct BHV {\n    data: array<BHVNode>,\n};\n\nstruct MeshFlags {\n    data: array<u32>,\n};\n\n\nstruct Ray {\n    origin: vec3<f32>,\n    t_min: f32,\n    direction: vec3<f32>,\n    t_max: f32,\n};\n\nstruct Rays {\n    data: array<Ray>,\n};\n\nstruct RayJob {\n    index: u32,\n    step: u32,\n}\n\nstruct PixelData {\n    world_pos: vec3<f32>,\n    depth: f32,\n    normal: vec3<f32>,\n    material_id: u32,\n    color: vec4<f32>,\n    uv_set: array<vec2<f32>, 4>,\n};\nfn quantize_unorm(v: f32, n: u32) -> u32 {\n    let scale = f32((1 << n) - 1);\n    return u32(0.5 + (v * scale));\n}\nfn quantize_snorm(v: f32, n: u32) -> u32 {\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if v < 0. {\n        return (u32(-v * scale) & c) | (1u << (n - 1u));\n    } else {\n        return u32(v * scale) & c;\n    }\n}\n\nfn decode_unorm(i: u32, n: u32) -> f32 {    \n    let scale = f32((1 << n) - 1);\n    if (i == 0u) {\n        return 0.;\n    } else if (i == u32(scale)) {\n        return 1.;\n    } else {\n        return (f32(i) - 0.5) / scale;\n    }\n}\n\nfn decode_snorm(i: u32, n: u32) -> f32 {\n    let s = i >> (n - 1u);\n    let c = (1u << (n - 1u)) - 1u;\n    let scale = f32(c);\n    if s > 0u {\n        let r = f32(i & c) / scale;\n        return -r;\n    } else {\n        return f32(i & c) / scale;\n    }\n}\n\n\nfn decode_as_vec3(v: u32) -> vec3<f32> {\n    let vx = decode_unorm((v >> 20u) & 0x000003FFu, 10u);\n    let vy = decode_unorm((v >> 10u) & 0x000003FFu, 10u);\n    let vz = decode_unorm(v & 0x000003FFu, 10u);\n    return vec3<f32>(vx, vy, vz);\n}\n\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn pack_4_f32_to_unorm(value: vec4<f32>) -> u32 {\n    let r = quantize_unorm(value.x, 8u) << 24u;\n    let g = quantize_unorm(value.y, 8u) << 16u;\n    let b = quantize_unorm(value.z, 8u) << 8u;\n    let a = quantize_unorm(value.w, 8u);\n    return (r | g | b | a);\n}\nfn unpack_snorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_snorm((v >> 24u) & 255u, 8u);\n    let g = decode_snorm((v >> 16u) & 255u, 8u);\n    let b = decode_snorm((v >> 8u) & 255u, 8u);\n    let a = decode_snorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\nfn unpack_unorm_to_4_f32(v: u32) -> vec4<f32> {\n    let r = decode_unorm((v >> 24u) & 255u, 8u);\n    let g = decode_unorm((v >> 16u) & 255u, 8u);\n    let b = decode_unorm((v >> 8u) & 255u, 8u);\n    let a = decode_unorm(v & 255u, 8u);\n    return vec4<f32>(r,g,b,a);\n}\n\n// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.\nfn hash( x: u32 ) -> u32 {\n    var v = x;\n    v += ( v << 10u );\n    v ^= ( v >>  6u );\n    v += ( v <<  3u );\n    v ^= ( v >> 11u );\n    v += ( v << 15u );\n    return v;\n}\n\nfn get_random_numbers(seed: vec2<u32>) -> vec2<u32> {\n    // This is PCG2D: https://jcgt.org/published/0009/03/02/\n    var new_seed = seed;\n    new_seed = 1664525u * new_seed + 1013904223u;\n    new_seed.x = new_seed.x + 1664525u * new_seed.y;\n    new_seed.y = new_seed.y + 1664525u * new_seed.x;\n    new_seed.x = new_seed.x ^ (new_seed.x >> 16u);\n    new_seed.y = new_seed.y ^ (new_seed.x >> 16u);\n    new_seed.x = new_seed.x + 1664525u * new_seed.y;\n    new_seed.y = new_seed.y + 1664525u * new_seed.x;\n    new_seed.x = new_seed.x ^ (new_seed.x >> 16u);\n    new_seed.y = new_seed.y ^ (new_seed.x >> 16u);\n    return new_seed;\n}\n\nfn swap_f32(ptr_a: ptr<function, f32>, ptr_b: ptr<function, f32>) \n{\n    let c = *ptr_a;\n    *ptr_a = *ptr_b;\n    *ptr_b = c;\n}\n\nfn has_vertex_attribute(vertex_attribute_layout: u32, attribute_to_check: u32) -> bool {\n    return bool(vertex_attribute_layout & attribute_to_check);\n}\nfn vertex_attribute_offset(vertex_attribute_layout: u32, attribute_to_check: u32) -> i32 \n{\n    if(has_vertex_attribute(vertex_attribute_layout, attribute_to_check)) {\n        let mask = vertex_attribute_layout & (~attribute_to_check & (attribute_to_check - 1u));\n        return i32(countOneBits(mask));\n    }\n    return -1;\n}\nfn vertex_layout_stride(vertex_attribute_layout: u32) -> u32 \n{\n    return countOneBits(vertex_attribute_layout);\n}\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) uv: vec2<f32>,\n};\n\nstruct FragmentOutput {\n    @location(0) color: vec4<f32>,\n};\n\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read> indices: Indices;\n@group(0) @binding(2)\nvar<storage, read> runtime_vertices: RuntimeVertices;\n@group(0) @binding(3)\nvar<storage, read> vertices_attributes: VerticesAttributes;\n@group(0) @binding(4)\nvar<storage, read> meshes: Meshes;\n@group(0) @binding(5)\nvar<storage, read> meshlets: Meshlets;\n\n@group(1) @binding(0)\nvar<storage, read> materials: Materials;\n@group(1) @binding(1)\nvar<storage, read> textures: Textures;\n@group(1) @binding(2)\nvar<storage, read> lights: Lights;\n@group(1) @binding(3)\nvar visibility_buffer_texture: texture_2d<f32>;\n\n\nfn extract_scale(m: mat4x4<f32>) -> vec3<f32> \n{\n    let s = mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz);\n    let sx = length(s[0]);\n    let sy = length(s[1]);\n    let det = determinant(s);\n    var sz = length(s[2]);\n    if (det < 0.) \n    {\n        sz = -sz;\n    }\n    return vec3<f32>(sx, sy, sz);\n}\n\nfn matrix_row(m: mat4x4<f32>, row: u32) -> vec4<f32> \n{\n    if (row == 1u) {\n        return vec4<f32>(m[0].y, m[1].y, m[2].y, m[3].y);\n    } else if (row == 2u) {\n        return vec4<f32>(m[0].z, m[1].z, m[2].z, m[3].z);\n    } else if (row == 3u) {\n        return vec4<f32>(m[0].w, m[1].w, m[2].w, m[3].w);\n    } else {        \n        return vec4<f32>(m[0].x, m[1].x, m[2].x, m[3].x);\n    }\n}\n\nfn normalize_plane(plane: vec4<f32>) -> vec4<f32> \n{\n    return (plane / length(plane.xyz));\n}\n\nfn rotate_vector(v: vec3<f32>, orientation: vec4<f32>) -> vec3<f32> \n{\n    return v + 2. * cross(orientation.xyz, cross(orientation.xyz, v) + orientation.w * v);\n}\n\nfn transform_vector(v: vec3<f32>, position: vec3<f32>, orientation: vec4<f32>, scale: vec3<f32>) -> vec3<f32> \n{\n    return rotate_vector(v, orientation) * scale + position;\n}\n\nstruct Derivatives {\n    dx: vec3<f32>,\n    dy: vec3<f32>,\n}\n\nfn compute_barycentrics(a: vec2<f32>, b: vec2<f32>, c: vec2<f32>, p: vec2<f32>) -> vec3<f32> {\n    let v0 = b - a;\n    let v1 = c - a;\n    let v2 = p - a;\n    \n    let d00 = dot(v0, v0);    \n    let d01 = dot(v0, v1);    \n    let d11 = dot(v1, v1);\n    let d20 = dot(v2, v0);\n    let d21 = dot(v2, v1);\n    \n    let inv_denom = 1. / (d00 * d11 - d01 * d01);    \n    let v = (d11 * d20 - d01 * d21) * inv_denom;    \n    let w = (d00 * d21 - d01 * d20) * inv_denom;    \n    let u = 1. - v - w;\n\n    return vec3 (u,v,w);\n}\n\n// Engel's barycentric coord partial derivs function. Follows equation from [Schied][Dachsbacher]\n// Computes the partial derivatives of point's barycentric coordinates from the projected screen space vertices\nfn compute_partial_derivatives(v0: vec2<f32>, v1: vec2<f32>, v2: vec2<f32>) -> Derivatives\n{\n    let d = 1. / determinant(mat2x2<f32>(v2-v1, v0-v1));\n    \n    var deriv: Derivatives;\n    deriv.dx = vec3<f32>(v1.y - v2.y, v2.y - v0.y, v0.y - v1.y) * d;\n    deriv.dy = vec3<f32>(v2.x - v1.x, v0.x - v2.x, v1.x - v0.x) * d;\n    return deriv;\n}\n\n// Interpolate 2D attributes using the partial derivatives and generates dx and dy for texture sampling.\nfn interpolate_2d_attribute(a0: vec2<f32>, a1: vec2<f32>, a2: vec2<f32>, deriv: Derivatives, delta: vec2<f32>) -> vec2<f32>\n{\n\tlet attr0 = vec3<f32>(a0.x, a1.x, a2.x);\n\tlet attr1 = vec3<f32>(a0.y, a1.y, a2.y);\n\tlet attribute_x = vec2<f32>(dot(deriv.dx, attr0), dot(deriv.dx, attr1));\n\tlet attribute_y = vec2<f32>(dot(deriv.dy, attr0), dot(deriv.dy, attr1));\n\tlet attribute_s = a0;\n\t\n\treturn (attribute_s + delta.x * attribute_x + delta.y * attribute_y);\n}\n\n// Interpolate vertex attributes at point 'd' using the partial derivatives\nfn interpolate_3d_attribute(a0: vec3<f32>, a1: vec3<f32>, a2: vec3<f32>, deriv: Derivatives, delta: vec2<f32>) -> vec3<f32>\n{\n\tlet attr0 = vec3<f32>(a0.x, a1.x, a2.x);\n\tlet attr1 = vec3<f32>(a0.y, a1.y, a2.y);\n\tlet attr2 = vec3<f32>(a0.z, a1.z, a2.z);\n    let attributes = mat3x3<f32>(a0, a1, a2);\n\tlet attribute_x = attributes * deriv.dx;\n\tlet attribute_y = attributes * deriv.dy;\n\tlet attribute_s = a0;\n\t\n\treturn (attribute_s + delta.x * attribute_x + delta.y * attribute_y);\n}\n// Need constant_data, meshlets, meshes, indices, runtime_vertices, vertices_attributes\n\nfn visibility_to_gbuffer(visibility_id: u32, screen_uv: vec2<f32>) -> PixelData \n{     \n    var uv_set: array<vec2<f32>, 4>;\n    var normal = vec3<f32>(0.);\n    var color = vec4<f32>(1.);\n\n    let meshlet_id = (visibility_id >> 8u) - 1u; \n    let primitive_id = visibility_id & 255u;\n    \n    let meshlet = &meshlets.data[meshlet_id];\n    let index_offset = (*meshlet).indices_offset + (primitive_id * 3u);\n\n    let mesh_id = u32((*meshlet).mesh_index);\n    let mesh = &meshes.data[mesh_id];\n    let material_id = u32((*mesh).material_index);\n    let position_offset = (*mesh).vertices_position_offset;\n    let attributes_offset = (*mesh).vertices_attribute_offset;\n    let vertex_layout = (*mesh).vertices_attribute_layout;\n    let vertex_attribute_stride = vertex_layout_stride(vertex_layout);   \n    let offset_color = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_COLOR);\n    let offset_normal = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_NORMAL);\n    let offset_uv0 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV1);\n    let offset_uv1 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV2);\n    let offset_uv2 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV3);\n    let offset_uv3 = vertex_attribute_offset(vertex_layout, VERTEX_ATTRIBUTE_HAS_UV4); \n\n    let vert_indices = vec3<u32>(indices.data[index_offset], indices.data[index_offset + 1u], indices.data[index_offset + 2u]);\n    let pos_indices = vert_indices + vec3<u32>(position_offset, position_offset, position_offset);\n    let attr_indices = vec3<u32>(attributes_offset + vert_indices.x * vertex_attribute_stride, \n                                 attributes_offset + vert_indices.y * vertex_attribute_stride,\n                                 attributes_offset + vert_indices.z * vertex_attribute_stride);\n    \n    let v1 = runtime_vertices.data[pos_indices.x].world_pos;\n    let v2 = runtime_vertices.data[pos_indices.y].world_pos;\n    let v3 = runtime_vertices.data[pos_indices.z].world_pos;\n    \n    let mvp = constant_data.proj * constant_data.view;\n    var p1 = mvp * vec4<f32>(v1, 1.);\n    var p2 = mvp * vec4<f32>(v2, 1.);\n    var p3 = mvp * vec4<f32>(v3, 1.);\n\n    // Calculate the inverse of w, since it's going to be used several times\n    let one_over_w = 1. / vec3<f32>(p1.w, p2.w, p3.w);\n    p1 = (p1 * one_over_w.x + 1.) * 0.5;\n    p2 = (p2 * one_over_w.y + 1.) * 0.5;\n    p3 = (p3 * one_over_w.z + 1.) * 0.5;\n    \n    // Get delta vector that describes current screen point relative to vertex 0\n    var screen_pixel = screen_uv.xy;\n    screen_pixel.y = 1. - screen_pixel.y;\n    let delta = screen_pixel + -p1.xy;\n    let barycentrics = compute_barycentrics(p1.xy, p2.xy, p3.xy, screen_pixel);\n    let deriv = compute_partial_derivatives(p1.xy, p2.xy, p3.xy);   \n\n    let world_pos = barycentrics.x * v1 + barycentrics.y * v2 + barycentrics.z * v3; \n    let depth = barycentrics.x * p1.z + barycentrics.y * p2.z + barycentrics.z * p3.z;  \n\n    if (offset_color >= 0) {\n        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_color)];\n        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_color)];\n        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_color)];\n        let c1 = unpack_unorm_to_4_f32(a1);\n        let c2 = unpack_unorm_to_4_f32(a2);\n        let c3 = unpack_unorm_to_4_f32(a3);\n        color = barycentrics.x * c1 + barycentrics.y * c2 + barycentrics.z * c3;    \n    }\n    if (offset_normal >= 0) {\n        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_normal)];\n        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_normal)];\n        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_normal)];\n        let n1 = decode_as_vec3(a1);\n        let n2 = decode_as_vec3(a2);\n        let n3 = decode_as_vec3(a3);\n        normal = barycentrics.x * n1 + barycentrics.y * n2 + barycentrics.z * n3;\n        normal = rotate_vector(normal, (*mesh).orientation); \n    }\n    if(offset_uv0 >= 0) {\n        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv0)];\n        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv0)];\n        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv0)];\n        let uv1 = unpack2x16float(a1);\n        let uv2 = unpack2x16float(a2);\n        let uv3 = unpack2x16float(a3);\n        uv_set[0] = interpolate_2d_attribute(uv1, uv2, uv3, deriv, delta);\n    }\n    if(offset_uv1 >= 0) {\n        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv1)];\n        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv1)];\n        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv1)];\n        let uv1 = unpack2x16float(a1);\n        let uv2 = unpack2x16float(a2);\n        let uv3 = unpack2x16float(a3);\n        uv_set[1] = interpolate_2d_attribute(uv1, uv2, uv3, deriv, delta);\n    }\n    if(offset_uv2 >= 0) {\n        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv2)];\n        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv2)];\n        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv2)];\n        let uv1 = unpack2x16float(a1);\n        let uv2 = unpack2x16float(a2);\n        let uv3 = unpack2x16float(a3);\n        uv_set[2] = interpolate_2d_attribute(uv1, uv2, uv3, deriv, delta);\n    }\n    if(offset_uv3 >= 0) {\n        let a1 = vertices_attributes.data[attr_indices.x + u32(offset_uv3)];\n        let a2 = vertices_attributes.data[attr_indices.y + u32(offset_uv3)];\n        let a3 = vertices_attributes.data[attr_indices.z + u32(offset_uv3)];\n        let uv1 = unpack2x16float(a1);\n        let uv2 = unpack2x16float(a2);\n        let uv3 = unpack2x16float(a3);\n        uv_set[3] = interpolate_2d_attribute(uv1, uv2, uv3, deriv, delta);\n    }    \n\n    return PixelData(world_pos, depth, normal, material_id, color, uv_set);\n}\n@group(2) @binding(0)\nvar default_sampler: sampler;\n\n@group(2) @binding(1)\nvar texture_1: texture_2d_array<f32>;\n@group(2) @binding(2)\nvar texture_2: texture_2d_array<f32>;\n@group(2) @binding(3)\nvar texture_3: texture_2d_array<f32>;\n@group(2) @binding(4)\nvar texture_4: texture_2d_array<f32>;\n@group(2) @binding(5)\nvar texture_5: texture_2d_array<f32>;\n@group(2) @binding(6)\nvar texture_6: texture_2d_array<f32>;\n@group(2) @binding(7)\nvar texture_7: texture_2d_array<f32>;\n\n\nfn sample_texture(tex_coords_and_texture_index: vec3<f32>) -> vec4<f32> {\n    let texture_data_index = i32(tex_coords_and_texture_index.z);\n    var v = vec4<f32>(0.);\n    var tex_coords = vec3<f32>(0.0, 0.0, 0.0);\n    if (texture_data_index < 0) {\n        return v;\n    }\n    let texture = &textures.data[texture_data_index];\n    let atlas_index = (*texture).texture_index;\n    let layer_index = i32((*texture).layer_index);\n\n    tex_coords.x = ((*texture).area.x + tex_coords_and_texture_index.x * (*texture).area.z) / (*texture).total_width;\n    tex_coords.y = ((*texture).area.y + tex_coords_and_texture_index.y * (*texture).area.w) / (*texture).total_height;\n    tex_coords.z = f32(layer_index);\n\n    switch (atlas_index) {\n        case 0u: { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 1u: { v = textureSampleLevel(texture_2, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 2u: { v = textureSampleLevel(texture_3, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 3u: { v = textureSampleLevel(texture_4, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 4u: { v = textureSampleLevel(texture_5, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 5u: { v = textureSampleLevel(texture_6, default_sampler, tex_coords.xy, layer_index, 0.); }\n        case 6u: { v = textureSampleLevel(texture_7, default_sampler, tex_coords.xy, layer_index, 0.); }\n        default { v = textureSampleLevel(texture_1, default_sampler, tex_coords.xy, layer_index, 0.); }\n    };\n    return v;\n}\nfn has_texture(material_id: u32, texture_type: u32) -> bool {\n    let material = &materials.data[material_id];\n    if ((*material).textures_indices[texture_type] >= 0) {\n        return true;\n    }\n    return false;\n}\n\nfn material_texture_index(material_id: u32, texture_type: u32) -> u32 {\n    let material = &materials.data[material_id];\n    let texture_index = (*material).textures_indices[texture_type];\n    if (texture_index < 0) {\n        return 0u;\n    }\n    return u32(texture_index);\n}\n\nfn material_texture_coord_set(material_id: u32, texture_type: u32) -> u32 {\n    let material = &materials.data[material_id];\n    return (*material).textures_coord_set[texture_type];\n}\n\nfn material_texture_uv(pixel_data: ptr<function, PixelData>, texture_type: u32) -> vec3<f32> {\n    let texture_coords_set = material_texture_coord_set((*pixel_data).material_id, texture_type);  \n    let texture_id = material_texture_index((*pixel_data).material_id, texture_type);\n    let uv = vec3<f32>((*pixel_data).uv_set[texture_coords_set], f32(texture_id));\n    return uv;\n} \n\nfn material_alpha(material_id: u32, vertex_color_alpha: f32) -> f32 {\n    let material = &materials.data[material_id];\n    \n    // NOTE: the spec mandates to ignore any alpha value in 'OPAQUE' mode\n    var alpha = 1.;\n    if ((*material).alpha_mode == MATERIAL_ALPHA_BLEND_OPAQUE) {\n        alpha = 1.;\n    } else if ((*material).alpha_mode == MATERIAL_ALPHA_BLEND_MASK) {\n        if (alpha >= (*material).alpha_cutoff) {\n            // NOTE: If rendering as masked alpha and >= the cutoff, render as fully opaque\n            alpha = 1.;\n        } else {\n            // NOTE: output_color.a < material.alpha_cutoff should not is not rendered\n            // NOTE: This and any other discards mean that early-z testing cannot be done!\n            alpha = -1.;\n        }\n    } else if ((*material).alpha_mode == MATERIAL_ALPHA_BLEND_BLEND) {\n        alpha = min((*material).base_color.a, vertex_color_alpha);\n    }\n    return alpha;\n}\n\nfn compute_normal(pixel_data: ptr<function, PixelData>) -> vec3<f32> {\n    var n = (*pixel_data).normal;\n    if (has_texture((*pixel_data).material_id, TEXTURE_TYPE_NORMAL)) {    \n        let uv = material_texture_uv(pixel_data, TEXTURE_TYPE_NORMAL);\n        // get edge vectors of the pixel triangle \n        let dp1 = dpdx( (*pixel_data).world_pos ); \n        let dp2 = dpdy( (*pixel_data).world_pos ); \n        let duv1 = dpdx( uv.xy ); \n        let duv2 = dpdy( uv.xy );   \n        // solve the linear system \n        let dp2perp = cross( dp2, n ); \n        let dp1perp = cross( n, dp1 ); \n        let tangent = dp2perp * duv1.x + dp1perp * duv2.x; \n        let bitangent = dp2perp * duv1.y + dp1perp * duv2.y;\n        let t = normalize(tangent);\n        let b = normalize(bitangent); \n        let tbn = mat3x3<f32>(t, b, n);\n        let tn = sample_texture(uv);\n        n = tbn * (2. * tn.rgb - vec3<f32>(1.));\n        n = normalize(n);\n    }\n    return n;\n}\n// Originally taken from https://github.com/KhronosGroup/glTF-WebGL-PBR\n// Commit a94655275e5e4e8ae580b1d95ce678b74ab87426\n//\n// This fragment shader defines a reference implementation for Physically Based Shading of\n// a microfacet surface material defined by a glTF model.\n//\n// References:\n// [1] Real Shading in Unreal Engine 4\n//     http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf\n// [2] Physically Based Shading at Disney\n//     http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf\n// [3] README.md - Environment Maps\n//     https://github.com/KhronosGroup/glTF-WebGL-PBR/#environment-maps\n// [4] \"An Inexpensive BRDF Model for Physically based Rendering\" by Christophe Schlick\n//     https://www.cs.virginia.edu/~jdl/bib/appearance/analytic%20models/schlick94b.pdf\n\nconst AMBIENT_COLOR: vec3<f32> = vec3<f32>(1., 1., 1.);\nconst AMBIENT_INTENSITY = 1.;\nconst NULL_VEC4: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 0.0);\nconst MIN_ROUGHNESS = 0.04;\n\n// Constant normal incidence Fresnel factor for all dielectrics.\nconst Fdielectric: vec3<f32> = vec3<f32>(0.04, 0.04, 0.04);\nconst Epsilon: f32 = 0.00001;\n\nstruct PBRData {\n    p: vec3<f32>,\n    n: vec3<f32>,\n    v: vec3<f32>,\n    specular_environmentR0: vec3<f32>,\n    specular_environmentR90: vec3<f32>,\n    diffuse_color: vec3<f32>,\n    alpha_roughness: f32,\n    final_color: vec4<f32>,\n};\n\n// GGX/Towbridge-Reitz normal distribution function.\n// Uses Disney's reparametrization of alpha = roughness^2.\nfn ndfGGX(cosLh: f32, roughness: f32) -> f32\n{\n\tlet alpha   = roughness * roughness;\n\tlet alphaSq = alpha * alpha;\n\n\tlet denom = (cosLh * cosLh) * (alphaSq - 1.0) + 1.0;\n\treturn alphaSq / (PI * denom * denom);\n}\n\n// Single term for separable Schlick-GGX below.\nfn gaSchlickG1(cosTheta: f32, k: f32) -> f32\n{\n\treturn cosTheta / (cosTheta * (1.0 - k) + k);\n}\n\n// Schlick-GGX approximation of geometric attenuation function using Smith's method.\nfn gaSchlickGGX(cosLi: f32, cosLo: f32, roughness: f32) -> f32\n{\n\tlet r = roughness + 1.0;\n\tlet k = (r * r) / 8.0; // Epic suggests using this roughness remapping for analytic lights.\n\treturn gaSchlickG1(cosLi, k) * gaSchlickG1(cosLo, k);\n}\n\n// Shlick's approximation of the Fresnel factor.\nfn fresnelSchlick(F0: vec3<f32>, cosTheta: f32) -> vec3<f32>\n{\n\treturn F0 + (vec3(1.0) - F0) * pow(1.0 - cosTheta, 5.0);\n}\n\n// The following equation models the Fresnel reflectance term of the spec equation (aka F())\n// Implementation of fresnel from [4], Equation 15\nfn specular_reflection(reflectance0: vec3<f32>, reflectance90: vec3<f32>, VdotH: f32) -> vec3<f32> {\n    return reflectance0 + (reflectance90 - reflectance0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);\n}\n// This calculates the specular geometric attenuation (aka G()),\n// where rougher material will reflect less light back to the viewer.\n// This implementation is based on [1] Equation 4, and we adopt their modifications to\n// alphaRoughness as input as originally proposed in [2].\nfn geometric_occlusion(alpha_roughness: f32, NdotL: f32, NdotV: f32) -> f32 {\n    let attenuationL = 2.0 * NdotL / (NdotL + sqrt(alpha_roughness * alpha_roughness + (1.0 - alpha_roughness * alpha_roughness) * (NdotL * NdotL)));\n    let attenuationV = 2.0 * NdotV / (NdotV + sqrt(alpha_roughness * alpha_roughness + (1.0 - alpha_roughness * alpha_roughness) * (NdotV * NdotV)));\n    return attenuationL * attenuationV;\n}\n\n// The following equation(s) model the distribution of microfacet normals across the area being drawn (aka D())\n// Implementation from \"Average Irregularity Representation of a Roughened Surface for Ray Reflection\" by T. S. Trowbridge, and K. P. Reitz\n// Follows the distribution function recommended in the SIGGRAPH 2013 course notes from EPIC Games [1], Equation 3.\nfn microfacet_distribution(alpha_roughness: f32, NdotH: f32) -> f32 {\n    let roughnessSq = alpha_roughness * alpha_roughness;\n    let f = (NdotH * roughnessSq - NdotH) * NdotH + 1.0;\n    return roughnessSq / (PI * f * f);\n}\n\nfn compute_color(material_id: u32, pixel_data: ptr<function, PixelData>) -> PBRData {\n    let material = &materials.data[material_id];\n        \n    let f0 = vec3<f32>(0.04);\n    var ao = 1.0;\n    var occlusion_strength = 1.;\n\n    if (has_texture(material_id, TEXTURE_TYPE_OCCLUSION)) {\n        let t = material_texture_uv(pixel_data, TEXTURE_TYPE_OCCLUSION);\n        ao = ao * t.r;\n        occlusion_strength = (*material).occlusion_strength;\n    }\n\n    var emissive_color = (*material).emissive_color;\n    if (has_texture(material_id, TEXTURE_TYPE_EMISSIVE)) {\n        let t = material_texture_uv(pixel_data, TEXTURE_TYPE_EMISSIVE);\n        emissive_color *= t.rgb;\n    }\n\n    var perceptual_roughness = (*material).roughness_factor;\n    var metallic = (*material).metallic_factor;\n    if (has_texture(material_id, TEXTURE_TYPE_METALLIC_ROUGHNESS)) {        \n        // Roughness is stored in the 'g' channel, metallic is stored in the 'b' channel.\n        // This layout intentionally reserves the 'r' channel for (optional) occlusion map data\n        let t = material_texture_uv(pixel_data, TEXTURE_TYPE_METALLIC_ROUGHNESS);\n        perceptual_roughness = perceptual_roughness * t.g;\n        metallic = metallic * t.b;\n    }\n    perceptual_roughness = clamp(perceptual_roughness, MIN_ROUGHNESS, 1.0);\n    metallic = clamp(metallic, 0.0, 1.0);\n    // Roughness is authored as perceptual roughness; as is convention,\n    // convert to material roughness by squaring the perceptual roughness [2].\n    let alpha_roughness = perceptual_roughness * perceptual_roughness;\n    \n    // Compute reflectance.\n    let specular_color = mix(f0, (*pixel_data).color.rgb, metallic);  \n    let reflectance = max(max(specular_color.r, specular_color.g), specular_color.b);\n\n    // For typical incident reflectance range (between 4% to 100%) set the grazing reflectance to 100% for typical fresnel effect.\n    // For very low reflectance range on highly diffuse objects (below 4%), incrementally reduce grazing reflecance to 0%.\n    let reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);\n    let specular_environmentR0 = specular_color.rgb;\n    let specular_environmentR90 = vec3<f32>(1., 1., 1.) * reflectance90;\n    \n    var diffuse_color = (*pixel_data).color.rgb * (vec3<f32>(1.) - f0);\n    diffuse_color = diffuse_color * (1. - metallic);\n        \n    var ambient_color = diffuse_color.rgb * AMBIENT_COLOR * AMBIENT_INTENSITY;\n    ambient_color = mix(ambient_color, ambient_color * ao, occlusion_strength);\n    let color = ambient_color;// + emissive_color;\n        \n    let final_color = vec4<f32>(color, (*pixel_data).color.a);\n\n    let p = (*pixel_data).world_pos;\n    let n = compute_normal(pixel_data);     // normal at surface point\n    let view_pos = constant_data.view[3].xyz;\n    let v = normalize(view_pos-(*pixel_data).world_pos); // Vector from surface point to camera\n\n    return PBRData(p, n, v, specular_environmentR0, specular_environmentR90, diffuse_color, alpha_roughness, final_color);\n}\n\nfn compute_brdf(pbr: PBRData) -> vec4<f32> {\n    var final_color = pbr.final_color;\n    let NdotV = clamp(abs(dot(pbr.n, pbr.v)), 0.0001, 1.0);\n    let num_lights = arrayLength(&lights.data);\n    for (var i = 0u; i < num_lights; i++ ) {\n        let light = &lights.data[i];\n        if ((*light).light_type == 0u) {\n            break;\n        }\n        \n        let dir = (*light).position - pbr.p;\n        let d = length(dir);\n        let l = normalize(dir);                             // Vector from surface point to light\n        let h = normalize(l + pbr.v);                           // Half vector between both l and v\n        \n        let linear_att = 0.5 * d;\n        let quad_att = 0.5 * d * d;\n        let light_intensity = (*light).intensity * 1000. / (linear_att * quad_att);\n        let light_contrib = light_intensity * (max((*light).range - d, (*light).range) / (*light).range);\n        \n        let NdotL = clamp(dot(pbr.n, l), 0.0001, 1.0);\n        let NdotH = clamp(dot(pbr.n, h), 0.0, 1.0);\n        let LdotH = clamp(dot(l, h), 0.0, 1.0);\n        let VdotH = clamp(dot(pbr.v, h), 0.0, 1.0);\n        \n        // Calculate the shading terms for the microfacet specular shading model\n        let F = specular_reflection(pbr.specular_environmentR0, pbr.specular_environmentR90, VdotH);\n        let G = geometric_occlusion(pbr.alpha_roughness, NdotL, NdotV);\n        let D = microfacet_distribution(pbr.alpha_roughness, NdotH);\n        \n        let diffuse_contrib = (1. - F) * pbr.diffuse_color / PI;\n        let spec_contrib = F * G * D / (4.0 * NdotL * NdotV);\n        var light_color = NdotL * (*light).color.rgb * (diffuse_contrib + spec_contrib);\n        \n        final_color = vec4<f32>(final_color.rgb + light_color * light_contrib, final_color.a);\n    }\n    return final_color;\n}\n\n@vertex\nfn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> VertexOutput {\n    //only one triangle, exceeding the viewport size\n    let uv = vec2<f32>(f32((in_vertex_index << 1u) & 2u), f32(in_vertex_index & 2u));\n    let pos = vec4<f32>(uv * vec2<f32>(2., -2.) + vec2<f32>(-1., 1.), 0., 1.);\n\n    var vertex_out: VertexOutput;\n    vertex_out.clip_position = pos;\n    vertex_out.uv = uv;\n    return vertex_out;\n}\n\n@fragment\nfn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {\n    var color = vec4<f32>(0.);\n    if v_in.uv.x < 0. || v_in.uv.x > 1. || v_in.uv.y < 0. || v_in.uv.y > 1. {\n        discard;\n    }\n    let d = vec2<f32>(textureDimensions(visibility_buffer_texture));\n    let pixel_coords = vec2<i32>(v_in.uv * d);\n    \n    let visibility_output = textureLoad(visibility_buffer_texture, pixel_coords.xy, 0);\n    let visibility_id = pack4x8unorm(visibility_output);\n    if (visibility_id == 0u || (visibility_id & 0xFFFFFFFFu) == 0xFF000000u) {\n        return color;\n    }\n    \n    let display_meshlets = constant_data.flags & CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS;\n    if (display_meshlets != 0u) \n    {\n        let meshlet_id = (visibility_id >> 8u); \n        let meshlet_color = hash(meshlet_id + 1u);\n        color = vec4<f32>(vec3<f32>(\n            f32(meshlet_color & 255u),\n            f32((meshlet_color >> 8u) & 255u),\n            f32((meshlet_color >> 16u) & 255u)\n        ) / 255., 1.);\n    }\n    else \n    {\n        var pixel_data = visibility_to_gbuffer(visibility_id, v_in.uv.xy);\n        let material_id = pixel_data.material_id;\n        if (has_texture(material_id, TEXTURE_TYPE_BASE_COLOR)) {  \n            let uv = material_texture_uv(&pixel_data, TEXTURE_TYPE_BASE_COLOR);\n            let texture_color = sample_texture(uv);\n            pixel_data.color *= texture_color;\n        }\n        let alpha = material_alpha(material_id, pixel_data.color.a);\n        if (alpha < 0.) {\n            discard;\n        }\n        let pbr_data = compute_color(material_id, &pixel_data);\n        color = compute_brdf(pbr_data);\n    }\n    return color;\n}\n"}
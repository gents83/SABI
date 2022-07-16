{"spirv_code":[],"wgsl_code":"\nfn pack_normal(normal: vec3<f32>) -> vec2<f32> {\n    return vec2<f32>(normal.xy * 0.5 + 0.5);\n}\nfn unpack_normal(uv: vec2<f32>) -> vec3<f32> {\n    return vec3<f32>(uv.xy * 2. - 1., sqrt(1.-dot(uv.xy, uv.xy)));\n}\n\nfn unpack_unorm_to_4_f32(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(((color >> 24u) / 255u) & 255u),\n        f32(((color >> 16u) / 255u) & 255u),\n        f32(((color >> 8u) / 255u) & 255u),\n        f32((color / 255u) & 255u),\n    );\n}\n\nfn hash(index: u32) -> u32 {\n    var v = index;\n    v = (v + 0x7ed55d16u) + (v << 12u);\n    v = (v ^ 0xc761c23cu) ^ (v >> 19u);\n    v = (v + 0x165667b1u) + (v << 5u);\n    v = (v + 0xd3a2646cu) ^ (v << 9u);\n    v = (v + 0xfd7046c5u) + (v << 3u);\n    v = (v ^ 0xb55a4f09u) ^ (v >> 16u);\n    return v;\n}\n\n// 0-1 from 0-255\nfn linear_from_srgb(srgb: vec3<f32>) -> vec3<f32> {\n    let cutoff = srgb < vec3<f32>(10.31475);\n    let lower = srgb / vec3<f32>(3294.6);\n    let higher = pow((srgb + vec3<f32>(14.025)) / vec3<f32>(269.025), vec3<f32>(2.4));\n    return select(higher, lower, cutoff);\n}\n\n// [u8; 4] SRGB as u32 -> [r, g, b, a]\nfn unpack_color(color: u32) -> vec4<f32> {\n    return vec4<f32>(\n        f32(color & 255u),\n        f32((color >> 8u) & 255u),\n        f32((color >> 16u) & 255u),\n        f32((color >> 24u) & 255u),\n    );\n}\n\nfn extract_scale(m: mat4x4<f32>) -> vec3<f32> {\n    let s = mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz);\n    let sx = length(s[0]);\n    let sy = length(s[1]);\n    let det = determinant(s);\n    var sz = length(s[2]);\n    if (det < 0.) {\n        sz = -sz;\n    }\n    return vec3<f32>(sx, sy, sz);\n}\n\nfn matrix_row(m: mat4x4<f32>, row: u32) -> vec4<f32> {\n    if (row == 1u) {\n        return vec4<f32>(m[0].y, m[1].y, m[2].y, m[3].y);\n    } else if (row == 2u) {\n        return vec4<f32>(m[0].z, m[1].z, m[2].z, m[3].z);\n    } else if (row == 3u) {\n        return vec4<f32>(m[0].w, m[1].w, m[2].w, m[3].w);\n    } else {        \n        return vec4<f32>(m[0].x, m[1].x, m[2].x, m[3].x);\n    }\n}\n\nfn normalize_plane(plane: vec4<f32>) -> vec4<f32> {\n    return (plane / length(plane.xyz));\n}\nlet MAX_TEXTURE_ATLAS_COUNT: u32 = 16u;\nlet MAX_TEXTURE_COORDS_SET: u32 = 4u;\n\nlet TEXTURE_TYPE_BASE_COLOR: u32 = 0u;\nlet TEXTURE_TYPE_METALLIC_ROUGHNESS: u32 = 1u;\nlet TEXTURE_TYPE_NORMAL: u32 = 2u;\nlet TEXTURE_TYPE_EMISSIVE: u32 = 3u;\nlet TEXTURE_TYPE_OCCLUSION: u32 = 4u;\nlet TEXTURE_TYPE_SPECULAR_GLOSSINESS: u32 = 5u;\nlet TEXTURE_TYPE_DIFFUSE: u32 = 6u;\nlet TEXTURE_TYPE_EMPTY_FOR_PADDING: u32 = 7u;\nlet TEXTURE_TYPE_COUNT: u32 = 8u;\n\nlet MATERIAL_ALPHA_BLEND_OPAQUE = 0u;\nlet MATERIAL_ALPHA_BLEND_MASK = 1u;\nlet MATERIAL_ALPHA_BLEND_BLEND = 2u;\n\nlet MESH_FLAGS_NONE: u32 = 0u;\nlet MESH_FLAGS_VISIBLE: u32 = 1u;\nlet MESH_FLAGS_OPAQUE: u32 = 2u; // 1 << 1\nlet MESH_FLAGS_TRANSPARENT: u32 = 4u;  // 1 << 2\nlet MESH_FLAGS_WIREFRAME: u32 = 8u; // 1 << 3\nlet MESH_FLAGS_DEBUG: u32 = 16u; // 1 << 4\nlet MESH_FLAGS_UI: u32 = 32u; // 1 << 5\n\nlet CONSTANT_DATA_FLAGS_NONE: u32 = 0u;\nlet CONSTANT_DATA_FLAGS_SUPPORT_SRGB: u32 = 1u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS: u32 = 2u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_SPHERE: u32 = 4u;\nlet CONSTANT_DATA_FLAGS_DISPLAY_MESHLETS_BOUNDING_BOX: u32 = 8u;\n\nstruct DrawVertex {\n    @location(0) position_and_color_offset: u32,\n    @location(1) normal_offset: i32,\n    @location(2) tangent_offset: i32,\n    @location(3) padding_offset: u32,\n    @location(4) uvs_offset: vec4<i32>,\n};\n\nstruct DrawInstance {\n    @location(5) mesh_index: u32,\n    @location(6) matrix_index: u32,\n};\n\nstruct ConstantData {\n    view: mat4x4<f32>,\n    proj: mat4x4<f32>,\n    screen_width: f32,\n    screen_height: f32,\n    flags: u32,\n};\n\nstruct LightData {\n    position: vec3<f32>,\n    light_type: u32,\n    color: vec4<f32>,\n    intensity: f32,\n    range: f32,\n    inner_cone_angle: f32,\n    outer_cone_angle: f32,\n};\n\nstruct TextureData {\n    texture_index: u32,\n    layer_index: u32,\n    total_width: f32,\n    total_height: f32,\n    area: vec4<f32>,\n};\n\nstruct DrawMaterial {\n    textures_indices: array<i32, 8>,//TEXTURE_TYPE_COUNT>,\n    textures_coord_set: array<u32, 8>,//TEXTURE_TYPE_COUNT>,\n    roughness_factor: f32,\n    metallic_factor: f32,\n    alpha_cutoff: f32,\n    alpha_mode: u32,\n    base_color: vec4<f32>,\n    emissive_color: vec3<f32>,\n    occlusion_strength: f32,\n    diffuse_color: vec4<f32>,\n    specular_color: vec4<f32>,\n};\n\nstruct DrawCommand {\n    vertex_count: u32,\n    instance_count: u32,\n    base_index: u32,\n    vertex_offset: i32,\n    base_instance: u32,\n};\n\nstruct DrawMesh {\n    vertex_offset: u32,\n    indices_offset: u32,\n    meshlet_offset: u32,\n    meshlet_count: u32,\n    material_index: i32,\n    matrix_index: i32,\n    mesh_flags: u32,\n};\n\nstruct DrawMeshlet {\n    vertex_offset: u32,\n    vertex_count: u32,\n    indices_offset: u32,\n    indices_count: u32,\n    center_radius: vec4<f32>,\n    cone_axis_cutoff: vec4<f32>,\n};\n\nstruct Lights {\n    data: array<LightData>,\n};\n\nstruct Textures {\n    data: array<TextureData>,\n};\n\nstruct Materials {\n    data: array<DrawMaterial>,\n};\n\nstruct Instances {\n    data: array<DrawInstance>,\n};\n\nstruct Commands {\n    data: array<DrawCommand>,\n};\n\nstruct Meshes {\n    data: array<DrawMesh>,\n};\n\nstruct Meshlets {\n    data: array<DrawMeshlet>,\n};\n\nstruct Vertices {\n    data: array<DrawVertex>,\n};\n\nstruct Matrices {\n    data: array<mat4x4<f32>>,\n};\n\nstruct PositionsAndColors {\n    data: array<vec4<f32>>,\n};\n\nstruct NormalsAndPadding {\n    data: array<vec4<f32>>,\n};\n\nstruct Tangents {\n    data: array<vec4<f32>>,\n};\n\nstruct UVs {\n    data: array<vec2<f32>>,\n};\n\n\nstruct VertexOutput {\n    @builtin(position) clip_position: vec4<f32>,\n    @location(0) uv: vec3<f32>,\n};\n\nstruct FragmentOutput {\n    @location(0) color: vec4<f32>,\n};\n\n@group(0) @binding(0)\nvar<uniform> constant_data: ConstantData;\n@group(0) @binding(1)\nvar<storage, read> meshes: Meshes;\n@group(0) @binding(2)\nvar<storage, read> meshlets: Meshlets;\n@group(0) @binding(3)\nvar<storage, read> matrices: Matrices;\n\n\nfn draw_line(uv: vec2<f32>, p1: vec2<f32>, p2: vec2<f32>, width: f32) -> f32 {\n    let d = p2 - p1;\n    let t = clamp(dot(d,uv-p1) / dot(d,d), 0., 1.);\n    let proj = p1 + d * t;\n    return 1. - smoothstep(0., width, length(uv - proj));\n}\n\nfn draw_circle(uv: vec2<f32>, center: vec2<f32>, radius: f32, width: f32) -> f32 {\n    let p = uv - center;\n    let d = sqrt(dot(p,p));\n    return 1. - smoothstep(0., width, abs(radius-d));\n}\n\n@vertex\nfn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> VertexOutput {\n    //only one triangle, exceeding the viewport size\n\tlet uv = vec2<f32>(f32((in_vertex_index << 1u) & 2u), f32(in_vertex_index & 2u));\n\tlet pos = vec4<f32>(uv * vec2<f32>(2., -2.) + vec2<f32>(-1., 1.), 0., 1.);\n\n    var vertex_out: VertexOutput;\n    vertex_out.clip_position = pos;\n    vertex_out.uv = vec3<f32>(uv.xy, f32(in_vertex_index));\n    return vertex_out;\n}\n\n\n@fragment\nfn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {    \n    let resolution = vec2<f32>(constant_data.screen_width, constant_data.screen_height);\n    let aspect_ratio = resolution.x / resolution.y;\n\tvar uv = (v_in.uv.xy * 2. - 1.);\n    uv.x *= aspect_ratio;\n\n    var color = vec4<f32>(1., 1., 1., 1.);\n    var t = 0.;\n    let radius = 0.2;\n    let line_width = 0.01;\n\n    let mvp = constant_data.proj * constant_data.view;\n\n    let num_meshes = arrayLength(&meshes.data);\n    for(var mesh_index = 0u; mesh_index < num_meshes; mesh_index++) {\n        let mesh = &meshes.data[mesh_index];\n        let m = &matrices.data[(*mesh).matrix_index];\n        for(var meshlet_index = (*mesh).meshlet_offset; meshlet_index < (*mesh).meshlet_offset + (*mesh).meshlet_count; meshlet_index++) {\n            let meshlet = &meshlets.data[meshlet_index];\n            let clip_position = mvp * (*m) * vec4<f32>((*meshlet).center_radius.xyz, 1.);\n            var c = clip_position.xy / resolution.xy;\n            c.x *= aspect_ratio;\n            t = max(t, draw_circle(uv, c, radius, line_width));\n        }\n    }\n    color = color * t;\n\n    return color;\n}\n"}
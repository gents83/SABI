spirv_code  wgsl_code 1struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) uv: vec2<f32>,
};

struct FragmentOutput {
    @location(0) color: vec4<f32>,
};

@group(0) @binding(0)
var source_texture: texture_2d<f32>;


const FXAA_SPAN_MAX: f32 = 8.;
const FXAA_REDUCE_MUL: f32 = 1. / 8.;
const FXAA_REDUCE_MIN: f32 = 1. / 128.;

fn fxaa(t: texture_2d<f32>, p: vec2<f32>, dimensions: vec2<f32>) -> vec3<f32> {

    // 1st stage - Find edge
	let rgbNW = textureLoad(t, vec2<u32>(p + vec2<f32>(-1., -1.) / dimensions), 0).rgb;
	let rgbNE = textureLoad(t, vec2<u32>(p + vec2<f32>(1., -1.) / dimensions), 0).rgb;
	let rgbSW = textureLoad(t, vec2<u32>(p + vec2<f32>(-1., 1.) / dimensions), 0).rgb;
	let rgbSE = textureLoad(t, vec2<u32>(p + vec2<f32>(1., 1.) / dimensions), 0).rgb;
	let rgbM = textureLoad(t, vec2<u32>(p), 0).rgb;

	let luma = vec3<f32>(0.299, 0.587, 0.114);
	let lumaNW = dot(rgbNW, luma);
	let lumaNE = dot(rgbNE, luma);
	let lumaSW = dot(rgbSW, luma);
	let lumaSE = dot(rgbSE, luma);
	let lumaM = dot(rgbM, luma);

	var dir: vec2<f32>;
	dir.x = -(lumaNW + lumaNE - (lumaSW + lumaSE));
	dir.y = lumaNW + lumaSW - (lumaNE + lumaSE);
	let lumaSum = lumaNW + lumaNE + lumaSW + lumaSE;
	let dirReduce = max(lumaSum * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
	let rcpDirMin = 1. / (min(abs(dir.x), abs(dir.y)) + dirReduce);
	dir = min(vec2<f32>(FXAA_SPAN_MAX), max(vec2<f32>(-FXAA_SPAN_MAX), dir * rcpDirMin)) / dimensions;
	let rgbA = 0.5 * (textureLoad(t, vec2<u32>(p + dir * (1. / 3. - 0.5)), 0).rgb + textureLoad(t, vec2<u32>(p + dir * (2. / 3. - 0.5)), 0).rgb);

    // 2nd stage - Blur
	let rgbB = rgbA * 0.5 + 0.25 * (textureLoad(t, vec2<u32>(p + dir * (0. / 3. - 0.5)), 0).rgb + textureLoad(t, vec2<u32>(p + dir * (3. / 3. - 0.5)), 0).rgb);
	let lumaB = dot(rgbB, luma);
	let lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
	let lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

	return select(rgbB, rgbA, lumaB < lumaMin || lumaB > lumaMax);
} 

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> VertexOutput {
    //only one triangle, exceeding the viewport size
    let uv = vec2<f32>(f32((in_vertex_index << 1u) & 2u), f32(in_vertex_index & 2u));
    let pos = vec4<f32>(uv * vec2<f32>(2., -2.) + vec2<f32>(-1., 1.), 0., 1.);

    var vertex_out: VertexOutput;
    vertex_out.clip_position = pos;
    vertex_out.uv = uv;
    return vertex_out;
}

@fragment
fn fs_main(v_in: VertexOutput) -> @location(0) vec4<f32> {
    let d = vec2<f32>(textureDimensions(source_texture));
    let pixel_coords = vec2<f32>(f32(v_in.uv.x * d.x + 0.5), f32(v_in.uv.y * d.y + 0.5));

    var out_color = vec4<f32>(0.); 

    //out_color = textureLoad(source_texture, vec2<u32>(pixel_coords), 0); 
    out_color = vec4<f32>(fxaa(source_texture, pixel_coords, d), 1.);

    return out_color;
}
  LB   J@(%
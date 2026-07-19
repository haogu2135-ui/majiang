shader_type canvas_item;
render_mode unshaded;

// 水墨溶解转场着色器 / Ink dissolve transition shader
// 用于屏幕切换时的水墨晕染过渡效果
// progress 从 0.0 -> 1.0 控制溶解进度

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 ink_color : source_color = vec4(0.012, 0.016, 0.020, 1.0);
uniform float edge_softness : hint_range(0.01, 0.3) = 0.08;
uniform float noise_scale : hint_range(10.0, 100.0) = 40.0;
uniform float swirl_strength : hint_range(0.0, 2.0) = 0.6;
uniform vec2 origin = vec2(0.5, 0.5);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amplitude * value_noise(p);
		p *= 2.1;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV;

	// Distance from origin with aspect correction
	vec2 centered = uv - origin;
	float dist = length(centered);

	// Swirl distortion for organic ink spread feel
	float angle = atan(centered.y, centered.x);
	float swirl = swirl_strength * (1.0 - dist) * progress;
	vec2 swirled_uv = uv + vec2(cos(angle + swirl), sin(angle + swirl)) * swirl * 0.05;

	// Multi-octave noise for ink edge
	float noise = fbm(swirled_uv * noise_scale);
	float fine_noise = value_noise(swirled_uv * noise_scale * 3.0) * 0.3;

	// Dissolve threshold based on distance and noise
	float threshold = progress * 1.4 - dist * 0.5;
	float dissolve = smoothstep(threshold - edge_softness, threshold + edge_softness, noise + fine_noise * 0.5);

	// Ink edge glow - faint gold at the dissolving boundary
	float edge_band = smoothstep(threshold - edge_softness * 2.0, threshold, noise) *
	                  smoothstep(threshold + edge_softness * 0.5, threshold, noise);
	vec3 edge_glow = vec3(0.82, 0.68, 0.32) * edge_band * 0.3;

	// Final color
	float alpha = 1.0 - dissolve;
	vec3 final_color = ink_color.rgb + edge_glow;

	COLOR = vec4(final_color, alpha * ink_color.a);
}

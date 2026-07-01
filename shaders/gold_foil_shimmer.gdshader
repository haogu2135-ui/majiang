shader_type canvas_item;
render_mode unshaded;

// 金箔流光着色器 v2 / Enhanced Gold foil shimmer shader
// 增强版：双流光带 + 更多闪烁粒子 + 虹彩偏移

uniform vec4 base_gold : source_color = vec4(0.92, 0.78, 0.38, 1.0);
uniform vec4 highlight_gold : source_color = vec4(1.0, 0.94, 0.62, 1.0);
uniform vec4 shadow_gold : source_color = vec4(0.62, 0.48, 0.18, 1.0);
uniform float shimmer_speed : hint_range(0.0, 3.0) = 0.8;
uniform float shimmer_angle : hint_range(0.0, 6.283) = 0.52;
uniform float shimmer_width : hint_range(0.02, 0.4) = 0.15;
uniform float grain_intensity : hint_range(0.0, 0.15) = 0.06;
uniform float sparkle_density : hint_range(0.0, 1.0) = 0.4;

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

void fragment() {
	vec2 uv = UV;

	// Primary shimmer band
	float diag = uv.x * cos(shimmer_angle) + uv.y * sin(shimmer_angle);
	float sweep = fract(diag - TIME * shimmer_speed);
	float band = smoothstep(0.0, shimmer_width, sweep) * smoothstep(shimmer_width * 2.0, shimmer_width, sweep);

	// Secondary shimmer band (opposite direction, slower)
	float diag2 = uv.x * cos(shimmer_angle + 1.2) + uv.y * sin(shimmer_angle + 1.2);
	float sweep2 = fract(diag2 + TIME * shimmer_speed * 0.5);
	float band2 = smoothstep(0.0, shimmer_width * 1.5, sweep2) * smoothstep(shimmer_width * 3.0, shimmer_width * 1.5, sweep2);

	// Foil grain texture - mimics hammered gold surface
	float grain = value_noise(uv * 120.0) * grain_intensity;
	float fine_grain = value_noise(uv * 280.0 + vec2(42.0, 17.0)) * grain_intensity * 0.5;
	float micro_grain = value_noise(uv * 500.0 + vec2(100.0, 200.0)) * grain_intensity * 0.25;

	// Micro-sparkles that catch light
	vec2 sparkle_coord = floor(uv * 60.0) + floor(vec2(TIME * 2.0, TIME * 1.3));
	float sparkle_noise = hash(sparkle_coord);
	float sparkle = step(1.0 - sparkle_density * 0.08, sparkle_noise) * 0.4;

	// Fine sparkle dust
	vec2 dust_coord = floor(uv * 120.0) + floor(vec2(TIME * 1.5, TIME * 0.9));
	float dust_noise = hash(dust_coord);
	float dust = step(1.0 - sparkle_density * 0.04, dust_noise) * 0.2;

	// Iridescent shift at band edges
	float iridescence = sin(band * 3.14159 * 2.0) * 0.04;

	// Blend gold tones based on shimmer position
	vec3 gold_color = mix(base_gold.rgb, shadow_gold.rgb, grain + fine_grain + micro_grain);
	gold_color = mix(gold_color, highlight_gold.rgb, band * 0.6 + band2 * 0.3 + sparkle + dust);

	// Subtle iridescent shift
	gold_color += vec3(iridescence * 0.5, iridescence * 0.3, -iridescence * 0.8);

	// Edge darkening for depth
	float edge_x = smoothstep(0.0, 0.08, uv.x) * smoothstep(1.0, 0.92, uv.x);
	float edge_y = smoothstep(0.0, 0.08, uv.y) * smoothstep(1.0, 0.92, uv.y);
	float edge = edge_x * edge_y;
	gold_color = mix(shadow_gold.rgb * 0.7, gold_color, edge);

	COLOR = vec4(gold_color, base_gold.a);
}

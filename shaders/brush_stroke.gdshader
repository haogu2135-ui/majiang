shader_type canvas_item;
render_mode unshaded;

// 墨迹笔触着色器 / Ink brush stroke shader
// 应用于笔触分隔线元素，添加墨迹晕染和枯笔效果

uniform vec4 ink_color : source_color = vec4(0.12, 0.16, 0.20, 1.0);
uniform float ink_bleed : hint_range(0.0, 0.05) = 0.015;
uniform float dry_brush_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float bleed_falloff : hint_range(1.0, 10.0) = 6.0;

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
	float noise = value_noise(UV * 80.0);
	float dry_mask = smoothstep(dry_brush_intensity, dry_brush_intensity + 0.3, noise);

	float fine_noise = value_noise(UV * 200.0 + vec2(50.0, 30.0));
	float fine_dry = smoothstep(dry_brush_intensity * 0.6, dry_brush_intensity * 0.6 + 0.4, fine_noise);
	dry_mask = min(dry_mask, fine_dry);

	float edge_dist = min(UV.x, 1.0 - UV.x);
	float bleed = smoothstep(0.0, ink_bleed * bleed_falloff, edge_dist);

	float press_gradient = smoothstep(0.0, 0.15, UV.y) * smoothstep(1.0, 0.85, UV.y);

	float start_press = 1.0 + 0.3 * smoothstep(0.1, 0.0, UV.y);

	float alpha = dry_mask * bleed * press_gradient * start_press * ink_color.a;

	COLOR = vec4(ink_color.rgb, alpha);
}

shader_type canvas_item;
render_mode unshaded, blend_add;

// 辉光/光晕着色器 v2 / Enhanced Glow bloom shader
// 增强版：日冕光环 + 星芒光晕 + 更自然的辉光

uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.88, 0.55, 1.0);
uniform float falloff_power : hint_range(1.0, 8.0) = 3.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 center = UV - 0.5;
	float dist = length(center) * 2.0;

	// Main glow - soft radial falloff
	float glow = 1.0 / (1.0 + pow(dist, falloff_power) * 2.0);

	// Corona ring effect - subtle bright ring at mid-distance
	float corona = exp(-pow((dist - 0.45) * 8.0, 2.0)) * 0.3;

	// Outer haze - very soft wide glow
	float haze = exp(-pow(dist * 3.0, 2.0)) * 0.2;

	// Star-like cross flare (4-point)
	float cross = 0.0;
	vec2 dirs[4] = vec2[](vec2(1.0, 0.0), vec2(0.0, 1.0), vec2(0.707, 0.707), vec2(-0.707, 0.707));
	for (int i = 0; i < 4; i++) {
		float d = abs(dot(center, dirs[i]));
		cross += exp(-pow(d * 20.0, 2.0)) * 0.08;
	}

	// Pulse breathing
	float pulse = 0.85 + 0.15 * sin(TIME * pulse_speed);

	// Organic noise to break up perfect circle
	float organic = 1.0 + (hash(UV * 20.0 + vec2(TIME * 0.1, TIME * 0.07)) - 0.5) * 0.08;
	float organic_ring = 1.0 + (hash(UV * 40.0 + vec2(TIME * 0.15, 0.0)) - 0.5) * 0.12;

	float alpha = (glow + corona + haze + cross) * intensity * pulse * organic * organic_ring;

	COLOR = vec4(glow_color.rgb, alpha * glow_color.a);
}

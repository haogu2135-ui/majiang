shader_type canvas_item;
render_mode unshaded;

// 水墨宣纸质感背景着色器 v2 / Enhanced Ink-wash rice paper background shader
// 增强版：动态墨迹飘移 + 更丰富的纸纹

uniform float grain_intensity : hint_range(0.0, 0.1) = 0.04;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform float brush_streak_intensity : hint_range(0.0, 0.1) = 0.02;
uniform float warmth : hint_range(-0.1, 0.2) = 0.06;
uniform float time_scale : hint_range(0.0, 1.0) = 0.0;

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

float fbm(vec2 p, int octaves) {
	float v = 0.0, amp = 0.5, freq = 1.0;
	for (int i = 0; i < 4; i++) {
		if (i >= octaves) break;
		v += amp * value_noise(p * freq);
		amp *= 0.5; freq *= 2.0;
	}
	return v;
}

void fragment() {
	vec4 tex_color = COLOR;

	// Layered grain for rich paper texture
	float grain = value_noise(UV * 400.0) * grain_intensity;
	grain += value_noise(UV * 800.0 + vec2(50.0, 30.0)) * grain_intensity * 0.5;
	grain += value_noise(UV * 1600.0 + vec2(120.0, 80.0)) * grain_intensity * 0.25;

	// Brush streaks - paper fiber texture
	float streak_base = UV.y * 60.0;
	float streak_wobble = sin(UV.x * 8.0 + 1.5) * 0.3;
	float streak = sin((streak_base + streak_wobble) * 3.14159) * 0.5 + 0.5;
	streak = smoothstep(0.93, 1.0, streak) * brush_streak_intensity;

	// Dynamic ink cloud drift when animated
	float drift_cloud = 0.0;
	if (time_scale > 0.0) {
		vec2 drift_uv = UV * 3.0 + vec2(TIME * 0.04 * time_scale, TIME * 0.02 * time_scale);
		drift_cloud = fbm(drift_uv, 3) * 0.04 * time_scale;
		drift_cloud -= fbm(drift_uv + vec2(1.5, 2.3), 3) * 0.025 * time_scale;
	}

	// Vignette
	vec2 center = UV - 0.5;
	float dist = length(center);
	float vignette = 1.0 - smoothstep(0.3, 0.85, dist) * vignette_strength;

	// Warm color shift
	vec3 warm_shift = vec3(warmth * 0.8, warmth * 0.3, -warmth * 0.4);

	// Gentle time-based grain shimmer
	float time_grain = 0.0;
	if (time_scale > 0.0) {
		time_grain = sin(TIME * 0.3 + UV.x * 20.0 + UV.y * 15.0) * grain_intensity * 0.3 * time_scale;
	}

	vec3 final_color = tex_color.rgb + warm_shift + grain - streak + drift_cloud + time_grain;
	final_color *= vignette;

	COLOR = vec4(clamp(final_color, 0.0, 1.0), tex_color.a);
}

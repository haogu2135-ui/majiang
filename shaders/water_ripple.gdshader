shader_type canvas_item;
render_mode unshaded;

// 水波纹着色器 v2 / Enhanced Water ripple shader
// 增强版：双层波纹 + 月光倒影 + 波光粼粼

uniform vec4 water_color : source_color = vec4(0.28, 0.48, 0.52, 0.18);
uniform vec4 highlight_color : source_color = vec4(0.52, 0.74, 0.82, 0.12);
uniform float ripple_speed : hint_range(0.0, 5.0) = 1.5;
uniform float wave_frequency : hint_range(1.0, 30.0) = 12.0;
uniform float wave_amplitude : hint_range(0.0, 0.05) = 0.02;
uniform int wave_count : hint_range(2, 8) = 4;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;

	// Primary wave layer
	float wave_pattern = 0.0;
	for (int i = 0; i < 4; i++) {
		if (i >= wave_count) break;
		float freq = wave_frequency * (1.0 + float(i) * 0.3);
		float phase = float(i) * 1.7 + TIME * ripple_speed * (0.8 + float(i) * 0.2);
		float amp = wave_amplitude * (1.0 - float(i) * 0.15);
		wave_pattern += sin(uv.x * freq * 6.283 + phase) * amp;
	}

	// Secondary wave layer (perpendicular)
	float wave_pattern2 = 0.0;
	for (int i = 0; i < 3; i++) {
		float freq = wave_frequency * 0.7 * (1.0 + float(i) * 0.4);
		float phase = float(i) * 2.1 + TIME * ripple_speed * 0.6 * (1.0 + float(i) * 0.3);
		float amp = wave_amplitude * 0.6 * (1.0 - float(i) * 0.2);
		wave_pattern2 += sin(uv.y * freq * 6.283 + phase) * amp;
	}

	vec2 displaced_uv = uv;
	displaced_uv.y += wave_pattern;
	displaced_uv.x += wave_pattern2;

	// Moonlight reflection
	float reflection_x = sin(uv.x * 30.0 - TIME * 0.5) * 0.5 + 0.5;
	float reflection_y = smoothstep(0.0, 0.5, uv.y) * smoothstep(1.0, 0.5, uv.y);
	float moon_reflection = pow(reflection_x, 4.0) * reflection_y * 0.15;

	// Sunlight sparkle effect (波光粼粼)
	vec2 sparkle_uv = uv * 40.0 + vec2(TIME * 0.7, TIME * 0.5);
	float sparkle = hash(floor(sparkle_uv));
	float sun_sparkles = step(0.985, sparkle) * 0.2 * smoothstep(0.0, 0.5, uv.y) * smoothstep(1.0, 0.5, uv.y);

	float shimmer = 0.5 + 0.5 * sin(uv.x * 20.0 + TIME * 2.0);
	float depth_fade = smoothstep(0.0, 0.3, uv.y) * smoothstep(1.0, 0.6, uv.y);

	// Wave crest highlights
	float crest = pow(max(0.0, sin(uv.x * wave_frequency * 6.283 + TIME * ripple_speed)), 8.0);
	float crest2 = pow(max(0.0, sin(uv.y * wave_frequency * 0.7 * 6.283 + TIME * ripple_speed * 0.6)), 8.0);

	vec4 base = water_color * depth_fade;
	vec4 highlight = highlight_color * (crest + crest2 * 0.5) * depth_fade;

	// Moon reflection
	vec4 reflection_color = vec4(0.78, 0.84, 0.72, moon_reflection * 0.5);

	COLOR = base + highlight + reflection_color + vec4(highlight_color.rgb * sun_sparkles, sun_sparkles * 0.3);
}

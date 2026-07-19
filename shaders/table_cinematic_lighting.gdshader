shader_type canvas_item;
render_mode unshaded;

uniform float exposure : hint_range(0.8, 1.4) = 1.12;
uniform float center_lift : hint_range(0.0, 0.35) = 0.16;
uniform float edge_falloff : hint_range(0.0, 0.35) = 0.12;
uniform vec3 key_tint : source_color = vec3(1.0, 0.94, 0.80);

void fragment() {
	vec4 source = COLOR;
	vec2 centered = (UV - vec2(0.5)) * vec2(0.82, 1.08);
	float radial = clamp(1.0 - length(centered), 0.0, 1.0);
	float center_light = smoothstep(0.12, 0.88, radial) * center_lift;
	float vignette = smoothstep(0.28, 0.94, length(centered)) * edge_falloff;
	vec3 lit = source.rgb * exposure;
	lit *= mix(vec3(1.0), key_tint, center_light);
	lit *= 1.0 + center_light - vignette;
	COLOR = vec4(lit, source.a);
}

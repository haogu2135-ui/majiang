shader_type canvas_item;
render_mode unshaded;

uniform vec4 icon_color : source_color = vec4(1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	COLOR = vec4(icon_color.rgb, source.a * icon_color.a);
}

shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform vec2 offset;

varying vec4 vertex_color;
void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	COLOR = texture(noise, UV/4.0 + offset);
	COLOR.a = t.a == 0.0 ? 0.0 : COLOR.a;
}

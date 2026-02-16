shader_type canvas_item;

//uniform sampler2D transition_texture: filter_nearest;
uniform float percent: hint_range(0.0, 1.0);
uniform vec4 transition_color: source_color;

void fragment() {
	COLOR.a = percent;
}

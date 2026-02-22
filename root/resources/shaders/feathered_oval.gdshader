shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.1, 0.08, 0.12, 1.0);
uniform float feather : hint_range(0.0, 1.0) = 0.3;
uniform float inner_radius : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // Normalise UV coordinates to -1.0 to 1.0 range centered at 0.5
    vec2 uv = UV * 2.0 - 1.0;

    // Calculate distance for an oval (can adjust x/y scale here if needed)
    float dist = length(uv);

    // Create a feathered edge
    float alpha = smoothstep(inner_radius + feather, inner_radius, dist);

    COLOR = vec4(color.rgb, color.a * alpha);
}

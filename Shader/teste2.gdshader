shader_type canvas_item;

uniform vec2 resolution = vec2(32.0, 32.0);
uniform vec3 line_color : source_color = vec3(0.2, 0.3, 0.5);
uniform float thickness : hint_range(0.1, 10.0, 0.1) = 0.5;
uniform float brightness : hint_range(0.1, 4.0, 0.1) = 3.0;

float draw_grid(vec2 uv) {
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	uv += vec2(0.4, 0.1 * TIME);

	float zoom = abs(sin(0.2)) * 40.0;
	float line_thickness = zoom * thickness / resolution.y;
	vec3 grid = smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv * zoom)) * line_color;

	float alpha = texture(TEXTURE, UV).a;

	// Descartar pixels totalmente transparentes
	if (alpha < 0.01) {
		discard;
	}

	COLOR = vec4(grid * brightness, alpha);
}

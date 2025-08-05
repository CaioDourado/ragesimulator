shader_type canvas_item;

uniform vec3 color : source_color;
uniform float num_cells: hint_range(2.0, 50.0, 1.0) = 10.0;
uniform float speed : hint_range(0.1, 2.0, 0.01) = 1.0;
uniform float smoothness : hint_range(0.5, 2.0, 0.01) = 0.5;
uniform float angle : hint_range(0.0, 360.0) = 45.0;

float rectangle(vec2 uv, float width, float height) {
    vec2 uv_cartesian = uv * 2.0 - 1.0;
    vec2 uv_reflected = abs(uv_cartesian);

    float dfx = step(width, uv_reflected.x);
    float dfy = step(height, uv_reflected.y);

    return max(dfx, dfy);
}

float rectanglef(vec2 uv, float width, float height, float feather) {
    vec2 uv_cartesian = uv * 2.0 - 1.0;
    vec2 uv_reflected = abs(uv_cartesian);

    float dfx = smoothstep(width, width + feather, uv_reflected.x);
    float dfy = smoothstep(height, height + feather, uv_reflected.y);

    return max(dfx, dfy);
}

void fragment() {
	vec2 igrid = floor(UV * num_cells) / num_cells;
	igrid.x += 2.0 - mod(TIME*speed, 4.0);
	vec2 fgrid = fract(UV * num_cells);
	float rect_mask = rectanglef(igrid, 0.001, 2.0, smoothness);
	float grid_mask = 1.0 - rectangle(fgrid, rect_mask, rect_mask);
	float emission_mask = 1.0 - rectangle(fgrid, rect_mask+0.1,rect_mask+0.1) - grid_mask;
	vec3 tex = texture(TEXTURE, UV).rgb;
	COLOR = vec4(mix(tex, vec3(1.0), emission_mask), 1.0);
	COLOR.a = clamp(emission_mask + grid_mask, 0.0, 1.0) * texture(TEXTURE, UV).a;
	COLOR.rgb += emission_mask * color.rgb * 5.0;
}

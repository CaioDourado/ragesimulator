shader_type canvas_item;

uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform float line_thickness : hint_range(0.001, 0.1) = 0.1;
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Corrigido: revelação de baixo para cima
    float reveal_mask = smoothstep(0.0, 0.01, UV.y - reveal_progress);

    // Corrigido: linha de brilho no topo da parte revelada
    float line = smoothstep(line_thickness, 0.0, abs(UV.y - reveal_progress));

    vec3 color_mix = mix(tex.rgb, line_color.rgb, line * 0.6);
    COLOR = vec4(color_mix, tex.a * reveal_mask);
}
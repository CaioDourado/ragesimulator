shader_type canvas_item;

// Cor do feixe de luz
uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Laranja
// Espessura do contorno
uniform float thickness : hint_range(1.0, 10.0) = 3.0;
// Velocidade da animação do feixe
uniform float speed : hint_range(0.1, 10.0) = 1.0;
// Suavidade do efeito
uniform float smoothness : hint_range(0.01, 1.0) = 0.1;

void fragment() {
    // Cor e alfa da textura original
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;

    // Ajusta a espessura baseada no tamanho real da textura para suportar sub-regiões
    vec2 pixel_offset = TEXTURE_PIXEL_SIZE * thickness;

    // Amostragem dos pixels vizinhos para detectar bordas
    float alpha_left = texture(TEXTURE, UV - vec2(pixel_offset.x, 0.0)).a;
    float alpha_right = texture(TEXTURE, UV + vec2(pixel_offset.x, 0.0)).a;
    float alpha_up = texture(TEXTURE, UV - vec2(0.0, pixel_offset.y)).a;
    float alpha_down = texture(TEXTURE, UV + vec2(0.0, pixel_offset.y)).a;

    // Cálculo da magnitude do gradiente (detecção de borda)
    float edge = length(vec2(alpha_left - alpha_right, alpha_up - alpha_down));

    // Coordenada polar para animar o brilho ao longo do contorno
    float angle = atan(UV.y - 0.5, UV.x - 0.5);
    float glow_phase = mod(angle + TIME * speed, 6.28318); // 2*PI para completar o ciclo

    // Aplicação do brilho com suavidade
    float glow = smoothstep(0.0, smoothness, edge) * smoothstep(0.0, smoothness, cos(glow_phase));

    // Cor final combinando a textura original com o brilho
    COLOR = tex_color + glow * glow_color;
    COLOR.a = tex_color.a; // Preserva a transparência original
}

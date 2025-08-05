shader_type canvas_item;

uniform float intensity;
uniform vec4 color : source_color;
uniform float speed;

float sample(in vec2 st, sampler2D tex){
	return texture(tex, st).a;
}

void fragment() {
	float t = TIME * speed;
	vec2 px = vec2(1.)/vec2(textureSize(TEXTURE, 0));

	float neighbor = sample(UV+px*vec2(1., 0.), TEXTURE) + sample(UV+px*vec2(0., 1.), TEXTURE) + sample(UV+px*vec2(-1., 0.), TEXTURE) + sample(UV+px*vec2(0., 1.), TEXTURE);
	float center = sample(UV, TEXTURE) * 4.;
	float edge = clamp(neighbor - center, 0., 1.);
	float lit = dot(UV-vec2(.5), vec2(cos(t), sin(t))) - t;
	lit = mod(lit, 1.);
	lit = pow(lit, 12.);

	//COLOR = vec4(vec3(1.)*vec3(4.), .4)
	COLOR = vec4(color.rgb*vec3(intensity), edge*lit);
}

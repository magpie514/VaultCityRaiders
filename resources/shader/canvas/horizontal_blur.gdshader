shader_type canvas_item;
render_mode blend_add;

uniform float radius = 16.0;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec4 col = vec4(0);
	float f = 1.0;
	for(f = 0.0; f < radius; f+=1.0){
		col += texture(TEXTURE, UV + vec2(f, 0.0) * ps) * ((radius-f) / radius);
		col += texture(TEXTURE, UV - vec2(f, 0.0) * ps) * ((radius-f) / radius);
	}
	COLOR = col / 1.2;
}

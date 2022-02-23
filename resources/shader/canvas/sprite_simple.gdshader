shader_type canvas_item;
render_mode blend_mix;

void fragment() {
	vec4 col; vec4 tmp;
	col = texture(TEXTURE, UV);
	if(col.a > 0.1) {
		COLOR = col;
	} else {
		col = texture(TEXTURE, UV + vec2(0.0, 1.0) * TEXTURE_PIXEL_SIZE);
		tmp = texture(TEXTURE, UV + vec2(1.0, 0.0) * TEXTURE_PIXEL_SIZE);
		if(col.a > 0.1 && tmp.a > 0.1) COLOR = vec4(col.r, col.g, col.b, 0.2);
		else COLOR = vec4(0.0,0.0,0.0,0.0);
	}
}
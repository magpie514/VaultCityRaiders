shader_type canvas_item;
render_mode blend_add;
uniform float fade = 1.0;
uniform sampler2D t;
void fragment(){
	vec4 col = texture(TEXTURE, UV);
	float luma = (col.r * 0.33) + (col.g * 0.5) + (col.b * 0.15) + 0.013;
	vec4 grad = texture(t, vec2(luma, 0.0));
	COLOR = vec4(grad.rgb, col.a*fade);
}
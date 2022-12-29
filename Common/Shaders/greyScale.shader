shader_type canvas_item;

void fragment() {
	vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = (orig.r + orig.b + orig.g) / 3.0f;
	COLOR = vec4(avg, avg, avg, 1.0f);
}
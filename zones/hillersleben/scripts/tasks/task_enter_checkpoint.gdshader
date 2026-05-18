shader_type spatial;

uniform float alpha = 1.0;
uniform vec4 tint_color : source_color = vec4(1.0);

//render_mode blend_mix;

void fragment() {
	ALBEDO = tint_color.rgb;
	ALPHA = alpha * tint_color.a;
}
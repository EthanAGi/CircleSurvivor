shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform float dim_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 screen_color = textureLod(screen_texture, SCREEN_UV, blur_amount);
	screen_color.rgb = mix(screen_color.rgb, vec3(0.0), dim_strength);
	COLOR = vec4(screen_color.rgb, 0.95);
}
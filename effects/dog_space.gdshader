shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 center_uv = vec2(0.5);
uniform float radius = 48.0;
uniform float amount = 0.0;
varying vec2 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float distance_from_center = length(local_position) / max(radius, 0.01);
	float falloff = pow(max(1.0 - distance_from_center * distance_from_center, 0.0), 2.0);
	// Локальная линза: фон немного растягивается к собаке, край плавно исчезает.
	vec2 source_uv = SCREEN_UV - (SCREEN_UV - center_uv) * amount * falloff;
	source_uv = clamp(source_uv, SCREEN_PIXEL_SIZE * 0.5, vec2(1.0) - SCREEN_PIXEL_SIZE * 0.5);
	float opacity = 1.0 - smoothstep(0.9, 1.0, distance_from_center);
	COLOR = vec4(texture(screen_texture, source_uv).rgb, opacity);
}

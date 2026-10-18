shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float pixel_size : hint_range(1.0, 32.0, 1.0) = 2.0;
uniform vec2 reference_resolution = vec2(1280.0, 720.0);

void fragment() {
	// Keep the same grid in scene coordinates as the window is resized.
	// Never sample blocks smaller than one physical screen pixel.
	vec2 block_size = max(vec2(max(pixel_size, 1.0)) / reference_resolution, SCREEN_PIXEL_SIZE);
	vec2 pixel_uv = (floor(SCREEN_UV / block_size) + 0.5) * block_size;
	pixel_uv = clamp(pixel_uv, SCREEN_PIXEL_SIZE * 0.5, vec2(1.0) - SCREEN_PIXEL_SIZE * 0.5);
	COLOR = vec4(texture(screen_texture, pixel_uv).rgb, 1.0);
}

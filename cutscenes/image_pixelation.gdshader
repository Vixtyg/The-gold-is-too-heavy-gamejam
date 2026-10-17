shader_type canvas_item;
render_mode unshaded;

// Block size in source texture pixels. One preserves the original resolution.
uniform float pixel_size : hint_range(1.0, 128.0, 1.0) = 12.0;
// Levels per RGB channel. Fewer levels produce a smaller, more posterized palette.
uniform int color_levels : hint_range(2, 32, 1) = 8;

varying vec4 sprite_tint;

void vertex() {
	// Keep the scene's fade animation and the sprite's own tint/opacity.
	sprite_tint = COLOR;
}

void fragment() {
	vec2 block_size = TEXTURE_PIXEL_SIZE * max(pixel_size, 1.0);
	vec2 pixel_uv = (floor(UV / block_size) + 0.5) * block_size;
	pixel_uv = clamp(pixel_uv, TEXTURE_PIXEL_SIZE * 0.5, vec2(1.0) - TEXTURE_PIXEL_SIZE * 0.5);
	vec4 sampled_color = texture(TEXTURE, pixel_uv);
	float steps = float(max(color_levels - 1, 1));
	sampled_color.rgb = floor(sampled_color.rgb * steps + 0.5) / steps;
	COLOR = sampled_color * sprite_tint;
}

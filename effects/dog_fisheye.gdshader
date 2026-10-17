shader_type canvas_item;
render_mode unshaded;

uniform float strength : hint_range(0.0, 3.0) = 0.8;
// PORT: небольшой рост вместе с эффектом, максимум +18% при strength = 3.
uniform float size_growth : hint_range(0.0, 0.4) = 0.18;
// Базовый размер остаётся отдельной настройкой.
uniform float visual_scale : hint_range(0.5, 4.0) = 1.0;
// Coordinates of the current animation frame within the source atlas.
uniform vec4 frame_uv_rect = vec4(0.0, 0.0, 1.0, 1.0);
// Непрозрачная область кадра: скрипт вычисляет её автоматически и кеширует.
uniform vec4 content_uv_rect = vec4(0.0, 0.0, 1.0, 1.0);
// PORT: центр/радиус линзы относительно рисунка, без прозрачных полей кадра.
uniform vec2 lens_center = vec2(0.5, 0.5);
uniform float lens_radius : hint_range(0.05, 1.0) = 1.0;

varying vec2 local_uv;
varying vec4 sprite_tint;

void vertex() {
	local_uv = (UV - frame_uv_rect.xy) / frame_uv_rect.zw;
	VERTEX *= visual_scale * (1.0 + size_growth * strength / 3.0);
	// Fragment COLOR already includes the original texture: keep the tint separately.
	sprite_tint = COLOR;
}

void fragment() {
	vec2 content_uv = (local_uv - content_uv_rect.xy) / content_uv_rect.zw;
	vec2 offset = (content_uv - lens_center) * 2.0;
	float radius_squared = dot(offset, offset) / (lens_radius * lens_radius);
	float falloff = pow(max(1.0 - radius_squared, 0.0), 2.0);
	// Нулевая деформация на краях рисунка сохраняет ширину и высоту собаки.
	float edge = max(abs(content_uv.x - 0.5), abs(content_uv.y - 0.5)) * 2.0;
	falloff *= 1.0 - smoothstep(0.8, 1.0, edge);
	float magnification = 1.0 + strength * 1.5 * falloff;
	vec2 warped_uv = lens_center + offset * 0.5 / magnification;
	vec2 source_uv = content_uv_rect.xy + warped_uv * content_uv_rect.zw;
	if (any(lessThan(source_uv, vec2(0.0))) || any(greaterThan(source_uv, vec2(1.0)))) {
		COLOR = vec4(0.0);
	} else {
		// Never sample a neighboring animation frame, including at atlas edges.
		vec2 half_pixel = TEXTURE_PIXEL_SIZE * 0.5;
		vec2 atlas_uv = frame_uv_rect.xy + source_uv * frame_uv_rect.zw;
		atlas_uv = clamp(atlas_uv, frame_uv_rect.xy + half_pixel,
			frame_uv_rect.xy + frame_uv_rect.zw - half_pixel);
		COLOR = texture(TEXTURE, atlas_uv) * sprite_tint;
	}
}

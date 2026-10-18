@tool
extends Camera2D
## Pixel size is measured in scene pixels (1280x720 in this project),
## and scales with the window. One disables the effect.

@export_range(1, 32, 1) var pixel_size: int = 3:
	set(value):
		pixel_size = clampi(value, 1, 32)
		_update_pixelation()


func _ready() -> void:
	get_viewport().size_changed.connect(_update_pixelation)
	_update_pixelation()


func _update_pixelation() -> void:
	var overlay := get_node_or_null("Pixelation/Overlay") as ColorRect
	if overlay == null:
		return
	var effect := overlay.material as ShaderMaterial
	if effect != null:
		effect.set_shader_parameter("pixel_size", float(pixel_size))
		effect.set_shader_parameter("reference_resolution", get_viewport_rect().size.max(Vector2.ONE))
	overlay.visible = pixel_size > 1

@tool
extends AnimatedSprite2D
## Self-contained effect: attach this script to an AnimatedSprite2D.
## PORT: скопируйте effects в корень проекта или измените эти два пути.
const EFFECT_SHADER: Shader = preload("res://effects/dog_fisheye.gdshader")
const SPACE_SHADER: Shader = preload("res://effects/dog_space.gdshader")
const MAX_STRENGTH: float = 3.0

# PORT: сила выпуклости, небольшого роста и линзы вокруг собаки.
@export_range(0.0, 3.0, 0.05) var strength: float = 0.8:
	set(value):
		strength = clampf(value, 0.0, MAX_STRENGTH)
		if is_instance_valid(_effect_material):
			_effect_material.set_shader_parameter("strength", strength)
		_update_space()

# PORT: размер настраивается независимо; 1 сохраняет исходный размер собаки.
@export_range(0.5, 4.0, 0.05) var visual_scale: float = 1.0:
	set(value):
		visual_scale = clampf(value, 0.5, 4.0)
		if is_instance_valid(_effect_material):
			_effect_material.set_shader_parameter("visual_scale", visual_scale)

# PORT: максимальная прибавка к размеру; 0.18 = +18% на максимуме эффекта.
@export_range(0.0, 0.4, 0.01) var size_growth: float = 0.18:
	set(value):
		size_growth = clampf(value, 0.0, 0.4)
		if is_instance_valid(_effect_material):
			_effect_material.set_shader_parameter("size_growth", size_growth)

# PORT: радиус в пикселях спрайта до его Scale (48 * 2.5 = 120 на текущей собаке).
@export_range(8.0, 120.0, 1.0) var space_radius: float = 48.0:
	set(value):
		space_radius = maxf(value, 8.0)
		_update_space()

# PORT: 0 отключает искажение окружения; увеличение усиливает только фон.
@export_range(0.0, 0.2, 0.005) var space_distortion: float = 0.08:
	set(value):
		space_distortion = clampf(value, 0.0, 0.2)
		_update_space()

# PORT: отключите тестовое управление при подключении к своему управлению.
# Измените две клавиши ниже, если Num 8 / Num 2 уже заняты в другом проекте.
@export var test_controls_enabled: bool = true
@export var increase_key: Key = 9
@export var decrease_key: Key = 2
@export_range(0.05, 1.0, 0.05) var test_step: float = 0.2

var _effect_material: ShaderMaterial
var _frame_bounds: Dictionary = {}
var _space_material: ShaderMaterial
var _space_lens: Polygon2D


func _ready() -> void:
	# A separate material per dog prevents one dog's controls affecting another.
	_effect_material = ShaderMaterial.new()
	_effect_material.shader = EFFECT_SHADER
	material = _effect_material
	_effect_material.set_shader_parameter("strength", strength)
	_effect_material.set_shader_parameter("visual_scale", visual_scale)
	_effect_material.set_shader_parameter("size_growth", size_growth)
	_create_space_lens()
	frame_changed.connect(_sync_frame_region)
	animation_changed.connect(_sync_frame_region)
	sprite_frames_changed.connect(_sync_frame_region)
	_sync_frame_region()


func _create_space_lens() -> void:
	# Узлы создаются автоматически: при переносе достаточно скопировать effects.
	# Снимок фона делается перед собакой, поэтому она не искажается повторно.
	_space_material = ShaderMaterial.new()
	_space_material.shader = SPACE_SHADER
	_space_lens = Polygon2D.new()
	_space_lens.name = "FishEyeSpace"
	_space_lens.show_behind_parent = true
	_space_lens.material = _space_material
	add_child(_space_lens)
	_update_space()


func _update_space() -> void:
	if not is_instance_valid(_space_lens):
		return
	var r := space_radius
	_space_lens.polygon = PackedVector2Array([
		Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)])
	_space_material.set_shader_parameter("radius", r)
	_space_material.set_shader_parameter("amount", strength * space_distortion)
	_space_lens.visible = strength > 0.0 and space_distortion > 0.0


func _process(_delta: float) -> void:
	if not is_instance_valid(_space_material):
		return
	# Учитываем камеру автоматически; ссылок на мир или Camera2D здесь нет.
	var viewport_size := get_viewport_rect().size
	if viewport_size.x > 0.0 and viewport_size.y > 0.0:
		_space_material.set_shader_parameter("center_uv",
			get_global_transform_with_canvas().origin / viewport_size)


func _unhandled_key_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not test_controls_enabled:
		return
	var key := event as InputEventKey
	if key == null or not key.pressed:
		return
	# No Input Map setup is needed in the destination project. Key repeat works too.
	if false :
		strength += test_step
	elif key.physical_keycode == decrease_key or key.keycode == decrease_key:
		strength -= test_step
	else:
		return
	get_viewport().set_input_as_handled()


func _sync_frame_region() -> void:
	if not is_instance_valid(_effect_material) or sprite_frames == null:
		return
	if not sprite_frames.has_animation(animation) or sprite_frames.get_frame_count(animation) == 0:
		return
	var frame_texture := sprite_frames.get_frame_texture(animation, frame)
	if frame_texture == null:
		return
	var uv_rect := Vector4(0.0, 0.0, 1.0, 1.0)
	if frame_texture is AtlasTexture:
		var atlas := frame_texture as AtlasTexture
		if atlas.atlas != null:
			var atlas_size := atlas.atlas.get_size()
			var region := atlas.region
			if region.size == Vector2.ZERO:
				region.size = atlas_size
			uv_rect = Vector4(region.position.x / atlas_size.x, region.position.y / atlas_size.y,
				region.size.x / atlas_size.x, region.size.y / atlas_size.y)
	_effect_material.set_shader_parameter("frame_uv_rect", uv_rect)
	# Читаем рисунок один раз на текстуру, а не каждый кадр анимации.
	if not _frame_bounds.has(frame_texture):
		var bounds := Rect2(0, 0, 1, 1)
		var frame_image := frame_texture.get_image()
		if frame_image != null and not frame_image.is_empty():
			var used := frame_image.get_used_rect()
			if used.has_area():
				var image_size := Vector2(frame_image.get_size())
				bounds = Rect2(Vector2(used.position) / image_size, Vector2(used.size) / image_size)
		_frame_bounds[frame_texture] = bounds
	var content: Rect2 = _frame_bounds[frame_texture]
	_effect_material.set_shader_parameter("content_uv_rect",
		Vector4(content.position.x, content.position.y, content.size.x, content.size.y))

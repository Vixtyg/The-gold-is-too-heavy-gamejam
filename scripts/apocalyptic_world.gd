extends Node2D

const FOOD_SCRIPT = preload("res://sandwich/junk_food.gd")
const LEGUME_SCRIPT = preload("res://legume/legume.gd")

@export_range(0.0, 3.0, 0.05) var sandwich_fattening_amount: float = 0.2
@export_range(0.1, 10.0, 0.1) var fear_screen_duration: float = 2.0
@export_range(0.05, 1.0, 0.05) var fear_fade_duration: float = 0.35

var _fear_active: bool = false
var _pause_before_fear: bool = false

@onready var _dog: CharacterBody2D = $Dog
@onready var _spawn_position: Vector2 = _dog.global_position
@onready var _fisheye: AnimatedSprite2D = $Dog/AnimatedSprite2D
@onready var _camera: Camera2D = $Dog/Camera2D
@onready var _fear_screen: CanvasLayer = $FearScreen
@onready var _fear_background: ColorRect = $FearScreen/Black


func _ready() -> void:
	_fisheye.test_controls_enabled = false
	_fisheye.size_growth = 0.18
	_camera.zoom = Vector2(2.0, 2.0)
	_camera.limit_left = -10000000
	_camera.limit_top = -10000000
	_camera.limit_right = 10000000
	_camera.limit_bottom = 10000000
	_camera.reset_smoothing()
	for child in get_children():
		if child.get_script() == FOOD_SCRIPT:
			child.SPEED = 20
			child.eaten.connect(_on_sandwich_eaten)
		elif child.get_script() == LEGUME_SCRIPT:
			child.body_entered.connect(_on_legume_body_entered)


func _on_sandwich_eaten() -> void:
	_fisheye.strength += sandwich_fattening_amount


func _on_legume_body_entered(body: Node) -> void:
	if body == _dog and not _fear_active:
		_fear_active = true
		_show_fear.call_deferred()


func _show_fear() -> void:
	var tree := get_tree()
	_pause_before_fear = tree.paused
	_dog.velocity = Vector2.ZERO
	_fisheye.play(&"idle")
	_fear_background.modulate.a = 0.0
	_fear_screen.show()
	tree.paused = true
	var fade_time := minf(fear_fade_duration, fear_screen_duration * 0.5)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_fear_background, "modulate:a", 1.0, fade_time)
	tween.tween_interval(maxf(fear_screen_duration - fade_time * 2.0, 0.0))
	# Return to spawn while the black background still fully covers the world.
	tween.tween_callback(_respawn_dog)
	tween.tween_property(_fear_background, "modulate:a", 0.0, fade_time)
	tween.tween_callback(_finish_fear)


func _finish_fear() -> void:
	_fear_screen.hide()
	get_tree().paused = _pause_before_fear
	_fear_active = false


func _respawn_dog() -> void:
	_dog.global_position = _spawn_position
	_dog.velocity = Vector2.ZERO
	_dog.reset_physics_interpolation()
	_camera.reset_smoothing()


func _exit_tree() -> void:
	if _fear_active:
		get_tree().paused = _pause_before_fear

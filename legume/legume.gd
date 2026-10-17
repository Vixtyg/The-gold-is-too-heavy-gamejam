@tool
extends RigidBody2D

## Назначьте физическое тело цели в инспекторе. Зависимостей от собаки нет.
@export var target: PhysicsBody2D

# how fast the legume can move
@export var speed := 50.0

# Скорость поворота в градусах в секунду.
@export_range(0.0, 720.0) var angular_speed: float = 180.0
## Направление конуса относительно тела; картинка салата не поворачивается.
@export_range(-180.0, 180.0, 1.0) var vision_direction_degrees: float = 0.0:
	set(value):
		vision_direction_degrees = value
		queue_redraw()
## Пауза после завершения каждого случайного поворота.
@export_range(0.1, 10.0, 0.1) var look_time_min: float = 0.5
@export_range(0.1, 10.0, 0.1) var look_time_max: float = 1.0

# field of view angle in degrees
@export_range(0.0, 360.0) var fov_degrees: float = 45.0:
	set(value):
		fov_degrees = value
		queue_redraw()
@export_range(0.0, 5000.0) var max_range: float = 300.0:
	set(value):
		max_range = value
		queue_redraw()
@export var show_vision: bool = true:
	set(value):
		show_vision = value
		queue_redraw()
@export var vision_color: Color = Color(1.0, 0.1, 0.1, 0.2):
	set(value):
		vision_color = value
		queue_redraw()

var _rng := RandomNumberGenerator.new()
var _searching: bool = false
var _turning: bool = false
var _search_angle: float = 0.0
var _look_remaining: float = 0.0


func _ready() -> void:
	if not Engine.is_editor_hint():
		_rng.randomize()
		body_entered.connect(_on_body_entered)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.angular_velocity = 0.0
	if Engine.is_editor_hint() or not is_instance_valid(target):
		_searching = false
		state.angular_velocity = 0.0
		state.linear_velocity = Vector2.ZERO
		return
	var fov_rad := deg_to_rad(fov_degrees)
	var from_legume_to_target: Vector2 = target.global_position - self.global_position
	var target_angle: float = self.get_angle_to(target.global_position)
	var angle_rad := wrapf(target_angle - deg_to_rad(vision_direction_degrees), -PI, PI)
	var sees_target: bool = (
		(fov_rad * -0.5) < angle_rad and angle_rad < (fov_rad * 0.5)
		and (from_legume_to_target.length() < max_range)
	)
	if not sees_target:
		_search(state)
		return

	_searching = false
	_turn_vision(target_angle, state.step)
	state.linear_velocity = from_legume_to_target.normalized() * speed


func _search(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = Vector2.ZERO
	if not _searching:
		_searching = true
		_pick_search_angle()
	if _turning:
		var angle := wrapf(_search_angle - deg_to_rad(vision_direction_degrees), -PI, PI)
		if absf(angle) > 0.01:
			_turn_vision(_search_angle, state.step)
			return
		_turning = false
		_look_remaining = _rng.randf_range(
			minf(look_time_min, look_time_max), maxf(look_time_min, look_time_max)
		)
		state.angular_velocity = 0.0
		return
	state.angular_velocity = 0.0
	_look_remaining -= state.step
	if _look_remaining <= 0.0:
		_pick_search_angle()


func _pick_search_angle() -> void:
	_search_angle = _rng.randf_range(-PI, PI)
	_turning = true


func _turn_vision(target_angle: float, delta: float) -> void:
	vision_direction_degrees = rad_to_deg(rotate_toward(
		deg_to_rad(vision_direction_degrees), target_angle, deg_to_rad(angular_speed) * delta
	))


func _on_body_entered(body: Node) -> void:
	if body == target:
		# Временная реакция на касание: удаляем только салат.
		#target.sprite.strength-=1
		#if (target.sprite.strength<1):
		#	target.sprite.strength=0
		#else:
		#	target.sprite.strength-=1
		target.position.x=1176
		target.position.y=46
		queue_free()


func _draw() -> void:
	if not show_vision or fov_degrees <= 0.0 or max_range <= 0.0:
		return
	var fov_rad := deg_to_rad(fov_degrees)
	var direction := deg_to_rad(vision_direction_degrees)
	var start_angle := direction - fov_rad * 0.5
	var end_angle := direction + fov_rad * 0.5
	var sector := PackedVector2Array()
	if fov_degrees < 360.0:
		sector.append(Vector2.ZERO)
	for index in range(65):
		var angle := lerpf(start_angle, end_angle, float(index) / 64.0)
		sector.append(Vector2(max_range, 0).rotated(angle))
	draw_colored_polygon(sector, vision_color)
	var outline := Color(vision_color, minf(vision_color.a * 2.5, 1.0))
	if fov_degrees < 360.0:
		draw_line(Vector2.ZERO, sector[1], outline, 1.5, true)
		draw_line(Vector2.ZERO, sector[-1], outline, 1.5, true)
	draw_arc(Vector2.ZERO, max_range, start_angle, end_angle, 65, outline, 1.5, true)

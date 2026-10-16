extends RigidBody2D

@export var target: CharacterBody2D

# how fast the legume can move
@export var speed := 10.0

# how fast the legume can rotate in degrees per tick
@export var angular_speed := 1.0

# field of view angle in degrees
@export var fov_degrees := 90.0
@export var max_range := 500.0

var fov_rad = deg_to_rad(fov_degrees)
var angular_speed_rad = deg_to_rad(angular_speed)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var from_legume_to_target: Vector2 = target.global_position - self.global_position
	var angle_rad: float = self.get_angle_to(target.global_position)
	var sees_target: bool = (
		(fov_rad * -0.5) < angle_rad and angle_rad < (fov_rad * 0.5)
		and (from_legume_to_target.length() < max_range)
	)
	if not sees_target:
		state.angular_velocity = 0
		state.linear_velocity = Vector2.ZERO
		return

	# BUG: Jitters when getting close to target
	state.angular_velocity = sign(angle_rad) * angular_speed_rad
	state.linear_velocity = from_legume_to_target.normalized() * speed


func _draw() -> void:
	return
	# BUG: Draws nonsense
	self.draw_arc(
		self.global_position, # Is this not the center?
		max_range,
		fov_rad * -0.5 + self.global_rotation,
		fov_rad * 0.5 + self.global_rotation,
		16,
		Color.AQUA,
	)

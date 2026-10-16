extends RigidBody2D

@export var target: CharacterBody2D

@export var speed := 500.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction := target.global_position - self.global_position
	state.linear_velocity =  direction.normalized() * speed

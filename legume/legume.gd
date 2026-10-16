extends RigidBody2D

@export var target_to_flee_from: CharacterBody2D

@export var flee_radius := 300.0
@export var flee_strength := 800.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction := self.global_position - target_to_flee_from.global_position
	var distance := direction.length()
	if distance < flee_radius:
		var falloff := 1.0 - distance / flee_radius # Closer = stronger push
		state.linear_velocity = direction.normalized() * flee_strength * falloff

extends StaticBody2D

@export var player: CharacterBody2D
@export_range(0.0, 3.0, 0.1) var required_strength: float = 1.0
var open: bool = false


func _process(_delta: float) -> void:
	if open or not is_instance_valid(player):
		return
	var strength: float = player.get_strength()
	if strength >= required_strength or is_equal_approx(strength, required_strength):
		$AnimationPlayer.play("open_door")
		open = true
		$CollisionShape2D.set_deferred("disabled", true)

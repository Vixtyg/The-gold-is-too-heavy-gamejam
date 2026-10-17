extends StaticBody2D

@export var player = CharacterBody2D
var open = false
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player.get_strength()>=2&&open==false):
		$AnimationPlayer.play("open_door")
		open=true
		$CollisionShape2D.disabled=true

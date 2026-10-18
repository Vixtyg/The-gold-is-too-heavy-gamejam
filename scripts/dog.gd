extends CharacterBody2D
## Top-down movement. The supplied side-view art faces right by default.

@export var speed: float = 240.0
@export var acceleration: float = 1600.0
@export var braking: float = 2000.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func get_strength() -> float:
	return sprite.get("strength")


func _physics_process(delta: float) -> void:
	# PORT: при переносе всей собаки добавьте эти 4 действия в Input Map
	# или замените их именами действий движения вашего проекта.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var rate := acceleration if direction != Vector2.ZERO else braking
	velocity = velocity.move_toward(direction * speed, rate * delta)
	move_and_slide()

	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0

	if velocity.length_squared() > 1.0:
		sprite.play(&"run")
	else:
		sprite.play(&"idle")

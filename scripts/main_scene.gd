extends Node2D

const FisheyeEffect = preload("res://effects/dog_fisheye.gd")

@export_range(0.0, 3.0, 0.05) var sandwich_fattening_amount: float = 1.0
@export_range(0.0, 3.0, 0.05) var salad_slimming_amount: float = 1.0

@onready var _dog: CharacterBody2D = $Dog
@onready var _fisheye: FisheyeEffect = $Dog/AnimatedSprite2D
@onready var _salad: RigidBody2D = $Salad


func _ready() -> void:
	_fisheye.test_controls_enabled = false
	_salad.body_entered.connect(_on_salad_body_entered)
	$sandwich.eaten.connect(_on_sandwich_eaten)


func _on_sandwich_eaten() -> void:
	_fisheye.strength += sandwich_fattening_amount


func _on_salad_body_entered(body: Node) -> void:
	if body == _dog and not _salad.is_queued_for_deletion():
		_salad.queue_free()
		_fisheye.strength -= salad_slimming_amount

extends Node2D

@export var player: CharacterBody2D
@export_file("*.txt") var dialogue_file: String = "res://dialogue_sans.txt"
@export_range(0.0, 10.0, 0.1) var repeat_delay: float = 1.0

var _first_lines: PackedStringArray = []
var _repeat_lines: PackedStringArray = []
var _has_talked: bool = false
var _talking: bool = false
var _cooldown_until_msec: int = 0

@onready var _dialogue: CanvasLayer = $Dialogue


func _ready() -> void:
	_load_dialogue()
	$TalkArea.body_entered.connect(_on_body_entered)
	_dialogue.finished.connect(_on_dialogue_finished)


func _load_dialogue() -> void:
	if not FileAccess.file_exists(dialogue_file):
		push_error("Sans dialogue file is missing: %s" % dialogue_file)
		return
	var repeat_section := false
	for raw_line in FileAccess.get_file_as_string(dialogue_file).split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty():
			continue
		if line.begins_with("//"):
			if "again" in line.to_lower():
				repeat_section = true
			continue
		if repeat_section:
			_repeat_lines.append(line)
		else:
			_first_lines.append(line)


func _on_body_entered(body: Node2D) -> void:
	if body != player or _talking or Time.get_ticks_msec() < _cooldown_until_msec:
		return
	var lines := _repeat_lines if _has_talked and not _repeat_lines.is_empty() else _first_lines
	if lines.is_empty():
		return
	_talking = true
	player.velocity = Vector2.ZERO
	player.sprite.play(&"idle")
	# Pause outside the physics callback that reported the contact.
	_dialogue.start.call_deferred(lines)


func _on_dialogue_finished() -> void:
	_has_talked = true
	_talking = false
	_cooldown_until_msec = Time.get_ticks_msec() + int(ceilf(repeat_delay * 1000.0))

extends Node2D
## Plays both ending panels in order, then returns to the main menu.

@export_group("Text animation")
@export_range(0.0, 5.0, 0.05) var first_text_delay: float = 1.0
@export_range(0.1, 5.0, 0.05) var text_reveal_duration: float = 1.2
@export_range(0.0, 5.0, 0.05) var text_pause: float = 0.65
@export_range(0.0, 150.0, 1.0) var text_rise_distance: float = 28.0
@export_group("Frame transitions")
@export_range(0.1, 3.0, 0.05) var frame_fade_duration: float = 0.6
@export_range(0.0, 10.0, 0.1) var frame_hold_duration: float = 2.5
@export_range(0.0, 10.0, 0.1) var ending_hold_duration: float = 4.0

@onready var _frames: Array[Node2D] = [$frame1, $frame2]
@onready var _text_groups: Array = [
	[$frame1/appearin1sec, $frame1/appearin2secs, $frame1/appearin3secs],
	[$frame2/Label, $frame2/Label2],
]


func _ready() -> void:
	for frame in _frames:
		frame.hide()
	for group in _text_groups:
		for label: Control in group:
			label.self_modulate.a = 0.0
	_play()


func _play() -> void:
	for index in range(_frames.size()):
		var frame := _frames[index]
		frame.modulate.a = 0.0
		frame.show()
		await _fade_frame(frame, 1.0)
		await get_tree().create_timer(first_text_delay).timeout
		var labels: Array = _text_groups[index]
		for text_index in range(labels.size()):
			await _reveal_text(labels[text_index])
			if text_index < labels.size() - 1 and text_pause > 0.0:
				await get_tree().create_timer(text_pause).timeout
		var hold := ending_hold_duration if index == _frames.size() - 1 else frame_hold_duration
		await get_tree().create_timer(hold).timeout
		await _fade_frame(frame, 0.0)
		frame.hide()
	GameManager.return_to_menu()


func _reveal_text(label: Control) -> void:
	var destination := label.position
	label.position.y += text_rise_distance
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", destination, text_reveal_duration)
	tween.tween_property(label, "self_modulate:a", 1.0, text_reveal_duration)
	await tween.finished


func _fade_frame(frame: Node2D, opacity: float) -> void:
	var tween := create_tween()
	tween.tween_property(frame, "modulate:a", opacity, frame_fade_duration)
	await tween.finished

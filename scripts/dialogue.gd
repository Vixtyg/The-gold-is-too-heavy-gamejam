extends CanvasLayer

signal finished

var _lines: PackedStringArray = []
var _line_index: int = 0
var _active: bool = false
var _was_paused: bool = false

@onready var _text: Label = $Layout/Panel/Margin/Content/Text
@onready var _progress: Label = $Layout/Panel/Margin/Content/Footer/Progress


func start(lines: PackedStringArray) -> void:
	if _active or lines.is_empty():
		return
	_lines = lines
	_line_index = 0
	_active = true
	_was_paused = get_tree().paused
	get_tree().paused = true
	_show_line()
	show()


func _input(event: InputEvent) -> void:
	if not _active or event.is_echo():
		return
	var advance := event.is_action_pressed("ui_accept")
	if event is InputEventKey and event.pressed:
		advance = advance or event.physical_keycode == KEY_E or event.keycode == KEY_E
	elif event is InputEventMouseButton:
		advance = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if advance:
		get_viewport().set_input_as_handled()
		advance_line()


func advance_line() -> void:
	if not _active:
		return
	_line_index += 1
	if _line_index < _lines.size():
		_show_line()
		return
	_active = false
	hide()
	# The listener starts the cooldown before world physics resumes.
	finished.emit()
	get_tree().paused = _was_paused


func _show_line() -> void:
	_text.text = _lines[_line_index]
	_progress.text = "%d / %d" % [_line_index + 1, _lines.size()]


func _exit_tree() -> void:
	if _active:
		get_tree().paused = _was_paused

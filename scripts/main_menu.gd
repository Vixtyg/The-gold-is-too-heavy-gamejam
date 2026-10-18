extends Control

var _time: float = 0.0
var _leaving: bool = false
var _button_tweens: Dictionary = {}

@onready var _dog: TextureRect = $Layout/Dog
@onready var _dog_home: Vector2 = _dog.position
@onready var _play: Button = $Layout/Buttons/Play
@onready var _quit: Button = $Layout/Buttons/Quit


func _ready() -> void:
	_play.pressed.connect(_start_playing)
	_quit.pressed.connect(_quit_game)
	for button: Button in [_play, _quit]:
		button.pivot_offset = button.size * 0.5
		button.mouse_entered.connect(_animate_button.bind(button, true))
		button.mouse_exited.connect(_animate_button.bind(button, false))
		button.focus_entered.connect(_animate_button.bind(button, true))
		button.focus_exited.connect(_animate_button.bind(button, false))
	_play.grab_focus()
	$Layout.modulate.a = 0.0
	create_tween().tween_property($Layout, "modulate:a", 1.0, 0.4)


func _process(delta: float) -> void:
	_time += delta
	_dog.position = _dog_home + Vector2(0.0, sin(_time * 1.8) * 5.0)
	_dog.rotation = sin(_time * 1.25) * 0.018


func _animate_button(button: Button, highlighted: bool) -> void:
	if _leaving:
		return
	if _button_tweens.has(button):
		_button_tweens[button].kill()
	var target_scale := 1.035 if highlighted or button.has_focus() else 1.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * target_scale, 0.18)
	_button_tweens[button] = tween


func _start_playing() -> void:
	if _leaving:
		return
	_leaving = true
	_play.disabled = true
	_quit.disabled = true
	var tween := create_tween()
	tween.tween_property($Transition, "color:a", 1.0, 0.22)
	await tween.finished
	GameManager.play_from_menu()


func _quit_game() -> void:
	get_tree().quit()

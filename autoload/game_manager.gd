extends Node

const MENU_SCENE := "res://scenes/menu.tscn"
const INTRO_SCENE := "res://scenes/intro.tscn"
const GAME_SCENE := "res://main_scene.tscn"
const GAME_OVER_SCENE := "res://scenes/game_over.tscn"

var _transition_pending: bool = false


# Вызывается из меню при начале новой игры.
func start_game() -> void:
	_change_scene(MENU_SCENE, INTRO_SCENE)


# Вызывается после завершения стартовой катсцены.
func finish_intro() -> void:
	_change_scene(INTRO_SCENE, GAME_SCENE)


# Вызывается игровой сценой при проигрыше (например, по окончании таймера).
func finish_game() -> void:
	_change_scene(GAME_SCENE, GAME_OVER_SCENE)


# Вызывается с экрана проигрыша; стартовая катсцена не повторяется.
func start_next_round() -> void:
	_change_scene(GAME_OVER_SCENE, GAME_SCENE)


func return_to_menu() -> void:
	_change_scene("", MENU_SCENE)


func _change_scene(expected_scene: String, next_scene: String) -> void:
	if _transition_pending:
		return

	var tree := get_tree()
	if expected_scene != "":
		if tree.current_scene == null:
			return
		if tree.current_scene.scene_file_path != expected_scene:
			return

	_transition_pending = true
	var error := tree.change_scene_to_file(next_scene)
	if error != OK:
		_transition_pending = false
		push_error("Не удалось открыть сцену %s: %s" % [next_scene, error_string(error)])
		return

	# Смена сцены завершается в конце кадра; не допускаем повторного перехода.
	await tree.scene_changed
	_transition_pending = false

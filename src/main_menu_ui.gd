extends Node

@export var root: Control
@export var b_exit: Button
@export var b_start: Button

func _ready() -> void:
	b_exit.pressed.connect(_exit_pressed)
	b_start.pressed.connect(_start_pressed)
	hub.game_state.state_changed.connect(func(state): root.visible = state == GameState.State.Menu)
	pass

func _exit_pressed():
	get_tree().quit()
	pass

func _start_pressed():
	hub.game_transition.start_game()
	pass

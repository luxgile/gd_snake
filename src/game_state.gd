extends Node
class_name GameState

enum State { None, Menu, Transition, Playing }
@export var current_state: State
signal state_changed(state: State)


func _init() -> void:
	hub.game_state = self
	pass


func change_state(new_state: State):
	current_state = new_state
	state_changed.emit(new_state)
	pass

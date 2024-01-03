extends Node

@export var text_combo: Label
@export var text_parts: Label
@export var bar_combo: ProgressBar

func _ready() -> void:
	hub.game_state.state_changed.connect(_game_state_changed)
	pass


func _game_state_changed(state):
	if state == GameState.State.Playing:
		_setup()
	pass

func _setup() -> void:
	text_combo.text = "x0"
	text_parts.text = "1"

	var snake = hub.snake
	snake.new_part_spawned.connect(func(part): text_parts.text = str(snake.parts.size()))
	snake.combo_updated.connect(func(combo): text_combo.text = "x" + str(snake.combo_count))
	pass


func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return

	bar_combo.max_value = hub.snake.get_combo_threshold()
	bar_combo.value = hub.snake.combo_energy
	pass

extends Node 
class_name Stats

const FILE_PATH := "user://savegame.save"

class RunData:
	var time_played := 0.0
	var times_played := 0
	var times_eaten := 0
	var times_dashed := 0
	var best_length := 1
	var best_time := 0
	var best_combo := 1

	func clone() -> RunData:
		var clone = RunData.new()
		clone.time_played = time_played
		clone.times_played = times_played
		clone.times_eaten = times_eaten
		clone.times_dashed = times_dashed
		clone.best_time = best_time
		clone.best_length = best_length
		clone.best_combo = best_combo
		return clone

var prev_data: RunData
var data: RunData

func _init() -> void:
	hub.stats = self
	pass

func _ready() -> void:
	hub.game_state.state_changed.connect(_state_changed)
	data = RunData.new()
	load_data()
	pass	

func _exit_tree() -> void:
	save_data()
	pass

func _process(delta: float) -> void:
	if hub.game_state.current_state == GameState.State.Playing:
		data.time_played += delta
	pass

func _state_changed(state): 
	if state == GameState.State.Playing:
		prev_data = data.clone()
		data.times_played += 1
		hub.snake.dash_started.connect(func(): data.times_dashed += 1)
		hub.snake.combo_updated.connect(func(combo): 
			if combo > data.best_combo:
				data.best_combo = combo)
		hub.snake.died.connect(func(): _on_snake_death())
	pass

func _on_snake_death():
	if hub.snake.parts.size() > data.best_length:
		data.best_length = hub.snake.parts.size()
	if hub.snake.time_alive > data.best_time:
		data.best_time = hub.snake.time_alive
	save_data()
	pass

func save_data():
	var data_file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	var save_var = func(v):
		var json_string = JSON.stringify(v)
		data_file.store_line(json_string)
		pass

	save_var.call(data.time_played)
	save_var.call(data.times_played)
	save_var.call(data.times_eaten)
	save_var.call(data.times_dashed)
	save_var.call(data.best_combo)
	save_var.call(data.best_length)
	save_var.call(data.best_time)
	pass


func load_data(): 
	if not FileAccess.file_exists(FILE_PATH):
		data = RunData.new()
		return

	var json = JSON.new()
	var data_file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var load_var = func():
		var json_string = data_file.get_line()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("Error loading file: ", json.get_error_message())
			return
		return json.data
	
	data = RunData.new()
	data.time_played = load_var.call()
	data.times_played = load_var.call()
	data.times_eaten = load_var.call()
	data.times_dashed = load_var.call()
	data.best_combo = load_var.call()
	data.best_length = load_var.call()
	data.best_time = load_var.call()
	pass

extends Node
class_name SnakeTimer

@export var snake : Snake
@export var eater: FoodEater
@export var start_time := 30
@export var time_food : Curve
@export var food_curve_time := 180.
@export var start_cutoff := 5.
@export var panel: Panel

static var effect: AudioEffectHighPassFilter
var time_alive := 0.
var time := 999.

func _ready() -> void:
	panel.modulate.a = 0.
	if effect == null:
		effect = AudioEffectHighPassFilter.new()
		AudioServer.add_bus_effect(AudioServer.get_bus_index("Master"), effect)

	effect.cutoff_hz = 10.
	hub.game_state.state_changed.connect(_on_state_changed)
	pass

func _exit_tree() -> void:
	pass

func _on_state_changed(state):
	if state == GameState.State.Playing:
		time = start_time
		time_alive = 0
		eater.food_eaten.connect(func(): time += time_food.sample(time_alive / food_curve_time))
	pass

func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing or snake.is_dead:
		return

	effect.cutoff_hz = lerp(2000., 10., min(time / start_cutoff, 1.))	
	panel.modulate.a = 1 - (time / start_cutoff)

	time_alive += delta
	time -= delta
	if time <= 0:
		snake.kill_snake()
		effect.cutoff_hz = 10.
		panel.modulate.a = 0.
	pass

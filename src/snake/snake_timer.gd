extends Node
class_name SnakeTimer

@export var snake : Snake
@export var eater: FoodEater
@export var start_time := 30
@export var time_food : Curve
@export var food_curve_time := 180.

var time_alive := 0.
var time := 999.

func _ready() -> void:
	hub.game_state.state_changed.connect(_on_state_changed)
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

	time_alive += delta
	time -= delta
	if time <= 0:
		snake.kill_snake()
	pass

extends BpmNode
class_name FoodGenerator

@export var planet: World
@export var s_food: PackedScene
@export var max_food: int = 5
@export var h_offset: float

var current_food: Array[Food] = []

func _ready() -> void:
	super._ready()
	hub.game_state.state_changed.connect(_gamestate_changed)
	pass

func _on_beat(_beat: int) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return

	if current_food.size() <= max_food:
		var spawn_point = _random_planet_point()
		var instanced_food = s_food.instantiate()	
		if instanced_food is Food:
			var food: Food = instanced_food
			food.position = spawn_point
			var up = spawn_point.normalized()
			var forward = up.cross(Vector3.FORWARD)
			food.look_at_from_position(spawn_point, spawn_point + forward, spawn_point + up)
			current_food.push_back(food)
			food.food_eaten.connect(func(): if current_food: current_food.erase(food))
			add_child(food)
	pass

func _random_planet_point() -> Vector3:
	var rnd_dir = RandomUtils.rand_sphere() 	
	var pos = rnd_dir * (planet.radius + h_offset)
	return pos 

func _gamestate_changed(state: GameState.State):
	if state == GameState.State.Transition:
		for food in current_food:
			food.queue_free()
		current_food.clear()
	pass

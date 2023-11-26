extends Node
class_name FoodGenerator

@export var planet: World
@export var s_food: PackedScene
@export var max_food: int = 5
@export var h_offset: float

var current_food: Array[Food] = []


func _process(delta: float) -> void:

	while current_food.size() <= max_food:
		var spawn_point = _random_planet_point()
		var instanced_food = s_food.instantiate()	
		if instanced_food is Food:
			var food: Food = instanced_food
			food.position = spawn_point
			current_food.push_back(food)
			food.food_eaten.connect(func(): current_food.erase(food))
			add_child(food)
	pass

func _random_planet_point() -> Vector3:
	var rnd_dir = RandomUtils.rand_sphere() 	
	var pos = rnd_dir * (planet.radius + h_offset)
	return pos 

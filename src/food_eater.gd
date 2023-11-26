extends Node3D
class_name FoodEater

@export var snake: Snake
@export var area: Area3D

func _ready() -> void:
	area.body_entered.connect(_body_entered)
	area.area_entered.connect(_area_entered)
	pass

func _area_entered(area: Area3D):
	if area is Obstacle:
		snake.kill_snake()
	pass

func _body_entered(node: Node3D):
	if node is Food:
		var food: Food = node
		for i in food.food_value:
			snake.spawn_new_part()
		food.eat_food()
	pass

 

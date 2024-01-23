extends Node3D
class_name FoodEater

@export var snake: Snake
@export var area: Area3D
@export var sfx: AudioStreamPlayer
@export var pitch_variation: float


func _ready() -> void:
	area.body_entered.connect(_body_entered)
	area.area_entered.connect(_area_entered)
	pass


func _area_entered(area: Area3D):
	if area is Obstacle and not snake.is_dashing():
		snake.kill_snake()
	pass


func _body_entered(node: Node3D):
	if node is Food:
		var food: Food = node
		hub.stats.data.times_eaten += 1
		snake.add_combo()
		for i in food.food_value + snake.combo_count - 1:
			snake.spawn_new_part()
		food.eat_food()
		sfx.pitch_scale = 1.0 + RandomUtils.rand_real() * pitch_variation
		sfx.play()
	pass

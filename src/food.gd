extends StaticBody3D
class_name Food

signal food_eaten

@export var food_value: int = 1

func eat_food() -> void:
	food_eaten.emit()
	queue_free()
	pass

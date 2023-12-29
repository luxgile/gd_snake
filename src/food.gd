extends StaticBody3D
class_name Food

@export var vfx: Node3D

signal food_eaten

@export var food_value: int = 1

func eat_food() -> void:
	food_eaten.emit()
	vfx.reparent(get_parent())
	queue_free()
	pass

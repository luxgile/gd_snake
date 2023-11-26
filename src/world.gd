extends Node3D 
class_name World

@export var radius: float

func get_up_dir(target: Vector3) -> Vector3:
	return (target - position).normalized()

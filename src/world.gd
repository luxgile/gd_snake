extends Node3D
class_name World

@export var radius: float
@export var animation: AnimationPlayer

func _init():
	hub.world = self
	pass

func spawn_planet():
	animation.play("spawn")
	pass

func despawn_planet():
	animation.play("despawn")
	pass

func get_up_dir(target: Vector3) -> Vector3:
	return (target - position).normalized()

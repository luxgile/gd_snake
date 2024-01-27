extends Node3D
class_name World

@export var radius: float
@export var animation: AnimationPlayer
@export var rotation_speed := 0.5

func _init():
	hub.world = self
	pass

func _process(delta: float) -> void:
	if hub.game_state.current_state == GameState.State.Menu:
		rotate_y(deg_to_rad(rotation_speed * delta))
	pass

func spawn_planet():
	animation.play("spawn")
	pass

func despawn_planet():
	animation.play("despawn")
	pass

func get_up_dir(target: Vector3) -> Vector3:
	return (target - position).normalized()

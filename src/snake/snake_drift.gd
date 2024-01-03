extends Node

@export var snake: Snake
@export var snake_root: Node3D
@export var drift_model_rot: float
@export_range(0, 1) var drift_smoothness: float = 0.95
@export var drift_vfx: GPUParticles3D
@export var turbo_vfx: GPUParticles3D

var rot_target: float
var curr_target: float


func _process(delta: float) -> void:
	rot_target = 0
	if snake.is_drifting:
		drift_vfx.emitting = true
		drift_vfx.rotation_degrees = Vector3(0, 180 if snake.is_drifting_right else 0, 0)
		rot_target = drift_model_rot
		rot_target *= -1 if snake.is_drifting_right else 1
	else:
		drift_vfx.emitting = false

	turbo_vfx.emitting = snake.in_turbo()

	curr_target = lerp(rot_target, curr_target, drift_smoothness)
	snake_root.quaternion = Quaternion.IDENTITY
	snake_root.rotate_z(deg_to_rad(curr_target))
	pass

extends Node

@export var snake: Snake
@export var snake_root: Node3D
@export var drift_model_rot: float
@export_range(0, 1) var drift_smoothness: float = 0.95
@export var drift_low_vfx: GPUParticles3D
@export var drift_high_vfx: GPUParticles3D
@export var drift_high_start_vfx: GPUParticles3D
@export var turbo_vfx: GPUParticles3D
@export var drift_low_sfx: AudioStreamPlayer
@export var drift_high_sfx: AudioStreamPlayer
@export var drift_high_start_sfx: AudioStreamPlayer
@export var drift_turbo_sfx: AudioStreamPlayer

var rot_target: float
var curr_target: float

func _ready() -> void:
	snake.turbo_started.connect(func(): drift_turbo_sfx.play())
	pass

func _process(delta: float) -> void:
	rot_target = 0
	if snake.is_drifting:
		drift_low_vfx.rotation_degrees = Vector3(0, 180 if snake.is_drifting_right else 0, 0)
		drift_high_vfx.rotation_degrees = Vector3(0, 180 if snake.is_drifting_right else 0, 0)
		rot_target = drift_model_rot
		rot_target *= -1 if snake.is_drifting_right else 1

	var low_drift = snake.is_drifting and not snake.has_enough_energy_for_turbo()
	drift_low_vfx.emitting = low_drift
	if low_drift and not drift_low_sfx.playing:
		drift_low_sfx.play()
	elif not low_drift:
		drift_low_sfx.stop()

	var high_drift = snake.is_drifting and snake.has_enough_energy_for_turbo()
	if high_drift and not drift_high_vfx.emitting:
		drift_high_start_vfx.restart()
		drift_high_start_vfx.emitting = true
		drift_high_start_sfx.play()

	drift_high_vfx.emitting = high_drift
	if high_drift and not drift_high_sfx.playing:
		drift_high_sfx.play()
	elif not high_drift:
		drift_high_sfx.stop()
	turbo_vfx.emitting = snake.in_turbo()

	curr_target = lerp(rot_target, curr_target, drift_smoothness)
	snake_root.quaternion = Quaternion.IDENTITY
	snake_root.rotate_z(deg_to_rad(curr_target))
	pass

extends Node3D
class_name LookAtCamera

@export var invert_forward: bool
@export_range(0, 1) var rot_smooth: float = 0

var _camera: Node3D

func _process(delta: float) -> void:
	if _camera != null:
		var cam_up = TUtils.up(_camera.transform)
		var local_forward = TUtils.forward(transform)
		var forward = (_camera.global_position - global_position).normalized()
		if invert_forward:
			forward *= -1
		forward = lerp(forward, local_forward, rot_smooth)
		look_at(global_position + forward, cam_up)
	else:
		_camera = get_viewport().get_camera_3d()
	pass

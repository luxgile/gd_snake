extends Camera3D

@export var target: Snake
@export var target_offset: Vector3
@export_range(0, 1) var position_smoothness: float
@export var distance: float
@export var look_offset: Vector3


func _process(delta: float) -> void:
	var local_offset = TUtils.local_dir(target.transform, target_offset) 
	var target_pos = target.position + local_offset + target.transform.basis.y * distance
	position = lerp(target_pos, position, position_smoothness) 

	var local_look_offset = TUtils.local_dir(target.transform, look_offset)
	var target_look = target.position + local_look_offset
	look_at(target_look, -target.transform.basis.z)

	pass

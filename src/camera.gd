extends Camera3D

@export var target: Node3D
@export var distance: float
@export var predict_target: float

var last_target_pos: Vector3

func _process(delta: float) -> void:
	position = target.position + target.transform.basis.y * distance
	var prediction = target.position + (position - last_target_pos).normalized() * predict_target
	look_at(prediction, -target.transform.basis.z)
	last_target_pos = target.position
	pass

extends Camera3D

@export var target: Node3D
@export var distance: float

func _process(delta: float) -> void:
	position = target.position + target.transform.basis.y * distance
	look_at(target.position, -target.transform.basis.z)
	pass

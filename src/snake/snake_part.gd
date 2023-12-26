extends Node3D
class_name SnakePart

@export var delay_position: int = 15
@export var pos_cacher: PositionCacher

var parent_pos_cacher: PositionCacher


func _ready() -> void:
	pos_cacher.fill_empty(transform.basis.z * 0.2)
	pass

func _process(delta: float) -> void:
	position = parent_pos_cacher.get_position_delayed(delay_position)
	pass

extends Node3D
class_name SnakePart

@export var delay_position: int = 15
@export var pos_cacher: PositionCacher

var parent_pos_cacher: PositionCacher


func init_pos_cacher():
	pos_cacher.fill_empty(position, transform.basis.z * 0.2)
	pass


func init_pos_cacher_with_prev():
	pos_cacher.copy_from_other(parent_pos_cacher)
	pass


func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return
	update_position()
	pass


func update_position() -> void:
	position = parent_pos_cacher.get_position_delayed(delay_position)
	pass

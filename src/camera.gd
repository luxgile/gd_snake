extends Camera3D
class_name SnakeCamera

@export var menu_pos: Node3D
@export var target_offset: Vector3
@export_range(0, 1) var position_smoothness: float
@export_range(0, 1) var position_smoothness_menu: float
@export_range(0, 1) var position_smoothness_dead: float
@export var distance: float
@export var distance_dead: float
@export var look_offset: Vector3
@export var offset_speed_mult: float
@export var fov_speed_div: float
@export var start_mode: GameState.State
@export var update_mode: GameState.State


func change_state(state: GameState.State):
	update_mode = state
	pass

func _ready() -> void:
	position = menu_pos.position
	pass


func _process(delta: float) -> void:
	if update_mode == GameState.State.Playing:
		_playing_update(delta)
	else:
		position = lerp(menu_pos.position, position, position_smoothness_menu)
		look_at(Vector3.ZERO)
	pass


func _playing_update(delta):
	var target = hub.snake
	var dist = distance if not target.is_dead else distance_dead
	var smooth = position_smoothness if not target.is_dead else position_smoothness_dead
	var target_dir = (target.position - position).normalized()
	var local_offset = TUtils.local_dir(target.transform, target_offset)
	local_offset += local_offset * target.curr_speed.length() * offset_speed_mult
	var target_pos = target.position + local_offset + target.transform.basis.y * (dist)
	position = lerp(target_pos, position, position_smoothness)

	var local_look_offset = TUtils.local_dir(target.transform, look_offset)
	var target_look = target.position + local_look_offset
	look_at(target_look, -target.transform.basis.z)

	fov = 75 + target.curr_speed.length() / fov_speed_div

	pass

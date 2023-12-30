extends Node
class_name PositionCacher

@export var target: Node3D
@export var frames_to_cache: int = 200

var cached_positions: Array[Vector3] = []

func _process(_delta: float) -> void:
	cached_positions.push_back(target.position)
	while cached_positions.size() > frames_to_cache:
		cached_positions.pop_front()
	pass

func get_position_delayed(frames_delayed: int) -> Vector3:
	if frames_delayed > frames_to_cache:
		print("Warning: Tried to get a position out of memory cache. Returning last cached position.")
		return cached_positions[-1]
	return 	cached_positions[frames_to_cache - 1 - frames_delayed]

func fill_empty(start: Vector3, delta: Vector3):
	var size_to_fill = frames_to_cache - cached_positions.size()
	var curr_delta = start
	for i in size_to_fill:
		cached_positions.push_back(curr_delta)
		curr_delta += delta
	pass

func copy_from_other(pos_cacher: PositionCacher):
	for pos in pos_cacher.cached_positions:
		cached_positions.push_back(pos)
	pass

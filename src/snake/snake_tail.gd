extends Node

@export var snake: Snake
@export var snake_dash: SnakeDash
@export var tail_parent: Node3D
@export var tail: Path3D
@export var s_portal_sub: PackedScene

var is_last_portal: bool
var dash_start_pos: Vector3

func _ready() -> void:
	snake_dash.portal_spawned.connect(func(vfx): _on_portal_spawned(vfx))
	pass

func _process(_delta: float) -> void:
	tail.curve.point_count = snake.parts.size() + 1
	var index = 1
	tail.curve.set_point_position(0, snake.global_position)
	for part in snake.parts:
		tail.curve.set_point_position(index, part.global_position)
		index += 1
	pass

func _on_portal_spawned(portal: Node3D):
	if not is_last_portal:
		dash_start_pos = portal.position
		is_last_portal = true
	else:
		is_last_portal = false
		var node = s_portal_sub.instantiate()
		node.top_level = true
		tail_parent.add_child(node)
		var path_node = node.get_child(0) #Terrible hack to get the path. I'm so sorry
		if path_node is Path3D:
			var path: Path3D = path_node
			path.curve.set_point_position(0, dash_start_pos)
			path.curve.set_point_position(1, portal.position)
			portal.tree_exiting.connect(func(): node.queue_free())
	pass

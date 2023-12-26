extends Node

@export var snake: Snake
@export var pos_cacher: PositionCacher
@export var s_vfx: PackedScene
@export var shrink_time: float = 0.5

var vfx_spawned: Array[Node3D] = []

func _ready() -> void:
	snake.dash_started.connect(_spawn_portal)
	snake.dash_ended.connect(_spawn_portal)
	pass

func _process(delta: float) -> void:
	for vfx in vfx_spawned:
		if (vfx.global_position - snake.parts[-1].global_position).length() < 1:
			var tween =	create_tween()
			tween.tween_property(vfx, "scale", Vector3.ZERO, shrink_time)
			tween.tween_callback(vfx.queue_free)
			vfx_spawned.erase(vfx)
	pass

func _spawn_portal():
	var vfx = s_vfx.instantiate();
	if vfx is Node3D:
		var node: Node3D = vfx
		node.global_position = snake.position
		node.top_level = true	
		add_child.call_deferred(node)
		vfx_spawned.push_back(node)
	pass

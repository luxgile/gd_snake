extends Node

@export var snake: Snake
@export var snake_root: Node3D
@export var dash_indicator: Node3D
@export var pos_cacher: PositionCacher
@export var s_vfx: PackedScene
@export var shrink_time: float = 0.5
@export var vfxs: GPUParticles3D

var vfx_spawned: Array[Node3D] = []

func _ready() -> void:
	snake.dash_started.connect(_spawn_portal)
	snake.dash_ended.connect(_spawn_portal)
	snake.dash_ready.connect(func(): dash_indicator.visible = true)
	pass

func _process(delta: float) -> void:
	for vfx in vfx_spawned:
		if (vfx.position - snake.parts[-1].global_position).length() < 1:
			var tween =	create_tween()
			tween.tween_property(vfx, "scale", Vector3.ZERO, shrink_time)
			tween.tween_callback(vfx.queue_free)
			vfx_spawned.erase(vfx)
	pass

func _spawn_portal():
	var vfx = s_vfx.instantiate();
	if vfx is Node3D:
		var node: Node3D = vfx
		node.top_level = true	
		add_child.call_deferred(node)
		node.position = snake.position
		vfx_spawned.push_back(node)

	if snake.is_dashing():
		snake_root.visible = false
	else:
		snake_root.visible = true
		dash_indicator.visible = false
		vfxs.restart()
		vfxs.emitting = true

	pass

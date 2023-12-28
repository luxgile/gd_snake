extends BpmNode

@export var snake: Snake
@export var snake_root: Node3D
@export var react_scale: float
@export var react_time: float

var tween: Tween

func _on_beat(beat: int) -> void: 
	if tween:
		tween.kill()

	snake_root.scale = Vector3.ONE * react_scale
	tween =	create_tween()
	tween.tween_property(snake_root, "scale", Vector3.ONE, react_time)
	pass

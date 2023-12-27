extends Node3D

@export var master: BpmMaster

func _ready() -> void:
	master.new_beat.connect(_on_beat)
	pass

func _on_beat(beat: int):
	scale = Vector3.ONE * 1.5
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.1)
	pass

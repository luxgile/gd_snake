extends Node
class_name BpmNode


func _ready() -> void:
	hub.bpm_master.new_beat.connect(_on_beat)
	pass


func _on_beat(beat: int):
	pass

extends StaticBody3D
class_name Food

@export var vfx: GPUParticles3D

signal food_eaten

@export var food_value: int = 1


func eat_food() -> void:
	food_eaten.emit()
	vfx.get_parent().remove_child(vfx)
	get_parent().add_child(vfx)
	vfx.global_position = position
	vfx.restart()
	vfx.emitting = true
	get_tree().create_timer(2.0).timeout.connect(func(): vfx.queue_free())
	queue_free()
	pass

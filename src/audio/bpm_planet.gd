extends BpmNode

@export var planet: MeshInstance3D
@export var color_curve: Gradient
@export var emissive_curve: Curve
@export var back_time: float

var timer = 0


func _on_beat(beat: int):
	timer = 0
	pass


func _process(delta: float) -> void:
	timer += delta
	var k = timer / back_time
	planet.material_override.set_shader_parameter("emissive_color", color_curve.sample(k))
	planet.material_override.set_shader_parameter("emissive", emissive_curve.sample(k))
	pass

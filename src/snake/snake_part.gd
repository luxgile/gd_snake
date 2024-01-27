extends Node3D
class_name SnakePart

@export var enabled := true
@export var delay_position: int = 15
@export var pos_cacher: PositionCacher
@export var visuals: Node3D
@export var vfx_dead: GPUParticles3D
@export var forcefield: GPUParticlesAttractorSphere3D

var parent_pos_cacher: PositionCacher


func init_pos_cacher():
	pos_cacher.fill_empty(position, transform.basis.z * 0.2)
	pass


func init_pos_cacher_with_prev():
	pos_cacher.copy_from_other(parent_pos_cacher)
	pass


func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return

	if not enabled:
		return

	update_position()
	pass


func update_position() -> void:
	if parent_pos_cacher != null:
		position = parent_pos_cacher.get_position_delayed(delay_position)
	pass

func kill_part() -> void:
	vfx_dead.restart()
	vfx_dead.emitting = true
	visuals.visible = false
	forcefield.strength = 0
	await get_tree().create_timer(5).timeout
	queue_free()
	pass

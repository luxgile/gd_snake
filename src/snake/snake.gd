extends CharacterBody3D
class_name Snake

@export_group("References")
@export var s_snake_part: PackedScene
@export var body_vfx: GPUParticles3D
@export var position_cacher: PositionCacher
@export var snake_head: Node3D
@export var animation: AnimationPlayer
@export var vfx_death: GPUParticles3D

@export_group("Init")
@export var starting_parts: int

@export_group("Settings")
@export var lifetime_per_part: Curve
@export var part_size_per_part: Curve
@export var height_offset: float
@export var height_wave: float
@export var wave_frequency: float

@export_subgroup("Movement")
@export var brake_speed: float = 10
@export var normal_speed: float = 10
@export var acc_speed: float = 10
@export_range(0, 1) var speed_lerp: float
@export var rot_speed: float = 1

@export_subgroup("Dash")
@export var dash_speed: float
@export var dash_cd: Timer
@export var dash_dur: Timer

@export_subgroup("Drifting")
@export var drift_rot: float
@export var drift_rot_range: float
@export var turbo_add_speed: float
@export var target_to_current_turbo_ratio: float
@export var energy_regen: float
@export var energy_drain: float
@export var min_energy_for_turbo: float

@export_subgroup("Combo")
@export var combo_threshold_start: float
@export var combo_threshold_add: float
@export var combo_added: float
@export var combo_drain: float
var combo_energy: float
var combo_count: int
signal combo_updated(combo: int)

var parts: Array[SnakePart] = []
var curr_speed: Vector3
var target_speed: Vector3
var wave_timer: float
var is_drifting: bool = false
var is_drifting_right: bool = false

var turbo_energy_accumulated: float
var turbo_energy_gained: float

var is_dead: bool

signal dash_started
signal dash_ended
signal dash_ready
signal new_part_spawned(part: SnakePart)


func get_combo_threshold():
	return combo_threshold_start + combo_count * combo_threshold_add


func is_dashing():
	return not dash_dur.is_stopped()


func dash_in_cd():
	return not dash_cd.is_stopped()


func in_turbo():
	return turbo_energy_gained > 0


func _ready() -> void:
	hub.snake = self
	hub.game_state.state_changed.connect(_game_state_changed)
	pass


func _exit_tree() -> void:
	hub.snake = null
	pass


func _game_state_changed(state):
	if state == GameState.State.Playing:
		_setup()
	pass


func _setup() -> void:
	_process(0.16)  #Hack to make sure the snake is positioned properly before caching positions
	dash_dur.timeout.connect(_on_dash_done)
	dash_cd.timeout.connect(func(): dash_ready.emit())
	position_cacher.fill_empty(position - TUtils.forward(transform), Vector3.ZERO)
	clear_combo()

	for i in starting_parts:
		spawn_new_part()
	pass


func _on_dash_done():
	dash_cd.start()
	position_cacher.process_mode = Node.PROCESS_MODE_PAUSABLE
	dash_ended.emit()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return

	var world = hub.world
	body_vfx.lifetime = lifetime_per_part.sample(parts.size())

	# Combo drain
	combo_energy -= combo_drain * delta
	if combo_energy <= 0:
		combo_energy = 0
		if combo_count > 0:
			remove_combo()

	var local_forward = -transform.basis.z.normalized()
	var world_up = (position - world.position).normalized()

	# vertical movement
	var wave_offset = 0
	if not is_dead and !is_dashing():
		wave_timer += delta
		wave_offset = sin(wave_timer * wave_frequency) * height_wave

	position = world.position + world_up * (world.radius + height_offset + wave_offset)

	if not is_dead and is_drifting:
		turbo_energy_accumulated += energy_regen * delta

	if not is_dead and Input.is_action_just_released("drift"):
		turbo_energy_gained = turbo_energy_accumulated
		turbo_energy_accumulated = 0

	if not is_dead and turbo_energy_gained > 0:
		turbo_energy_gained -= energy_drain * delta

	if not is_dead and not is_dashing():
		_rotation_mov(world_up, delta)

	_horizontal_mov(delta)

	if not is_dead and Input.is_action_just_released("drift"):
		curr_speed = curr_speed.normalized() * target_speed.length()

	if not is_dead and Input.is_action_pressed("dash") and dash_cd.is_stopped() and not is_dashing():
		is_drifting = false
		dash_dur.start()
		position_cacher.process_mode = Node.PROCESS_MODE_DISABLED
		dash_started.emit()

	# Rotate head to always orbit around planet
	local_forward = world_up.cross(transform.basis.x)
	var target = position + local_forward
	look_at(target, world_up)
	pass


func _rotation_mov(world_up: Vector3, delta: float) -> float:
	var delta_rotation = 0
	if Input.is_action_pressed("rotate_left"):
		delta_rotation += rot_speed
	if Input.is_action_pressed("rotate_right"):
		delta_rotation -= rot_speed
	if abs(delta_rotation) > 0.1:
		if Input.is_action_pressed("drift") and not is_drifting:
			is_drifting = true
			is_drifting_right = true if delta_rotation < 0 else false

	if Input.is_action_just_released("drift"):
		is_drifting = false

	if is_drifting:
		delta_rotation = -drift_rot if is_drifting_right else drift_rot
		if Input.is_action_pressed("rotate_left"):
			delta_rotation += drift_rot_range
		if Input.is_action_pressed("rotate_right"):
			delta_rotation -= drift_rot_range

	rotate(world_up, delta_rotation * delta)
	return delta_rotation


func _horizontal_mov(delta: float) -> void:
	var forward = TUtils.forward(transform)
	var speed_magnitude = normal_speed
	if is_dashing():
		speed_magnitude = dash_speed
	else:
		if Input.is_action_pressed("brake"):
			speed_magnitude = brake_speed
		elif Input.is_action_pressed("accelerate"):
			speed_magnitude = acc_speed

		if in_turbo():
			speed_magnitude += turbo_add_speed

	if not is_dead:
		target_speed = forward * speed_magnitude

	curr_speed = lerp(target_speed, curr_speed, speed_lerp)
	move_and_collide(curr_speed * delta)
	pass


func clear_combo():
	combo_energy = 0
	combo_count = 0
	combo_updated.emit(combo_count)
	pass


func remove_combo():
	combo_count -= 1
	combo_energy = get_combo_threshold() - 0.01
	combo_updated.emit(combo_count)
	pass


func add_combo():
	combo_energy += combo_added
	if combo_energy > get_combo_threshold():
		combo_energy -= get_combo_threshold()
		combo_count += 1
		combo_updated.emit(combo_count)
	pass


func spawn_new_part():
	var new_part = s_snake_part.instantiate()
	if new_part is SnakePart:
		var snake_part: SnakePart = new_part
		snake_part.top_level = true
		if parts.size() == 0:
			snake_part.parent_pos_cacher = position_cacher
			snake_part.position = position
		else:
			snake_part.parent_pos_cacher = parts[-1].pos_cacher
			snake_part.position = parts[-1].position
		snake_part.init_pos_cacher_with_prev()
		snake_part.update_position()
		parts.push_back(snake_part)
		add_child.call_deferred(snake_part)
		new_part_spawned.emit(snake_part)
	_update_parts_visuals()
	pass


func _update_parts_visuals():
	for i in parts.size():
		var p = i as float / parts.size() as float
		parts[i].scale = Vector3.ONE * part_size_per_part.sample(p)
	pass


func kill_snake():
	print("TODO: Kill the snake")
	is_dead = true
	snake_head.visible = false
	vfx_death.restart()
	vfx_death.emitting = true
	target_speed = Vector3.ZERO
	pass

func spawn_anim():
	animation.play("spawn")
	pass

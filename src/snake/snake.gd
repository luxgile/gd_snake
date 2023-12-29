extends CharacterBody3D
class_name Snake

@export_group("References")
@export var s_snake_part: PackedScene
@export var world: World 
@export var body_vfx: GPUParticles3D
@export var position_cacher: PositionCacher
@export var snake_head: Node3D

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

var parts: Array[SnakePart] = []
var curr_speed: Vector3
var target_speed: Vector3
var wave_timer: float
var is_drifting: bool = false
var is_drifting_right: bool = false

var turbo_energy_accumulated: float
var turbo_energy_gained: float

signal dash_started
signal dash_ended
signal dash_ready
signal new_part_spawned(part: SnakePart)

func is_dashing(): return not dash_dur.is_stopped()
func dash_in_cd(): return not dash_cd.is_stopped()
func in_turbo(): return turbo_energy_gained > 0

func _ready() -> void:
	dash_dur.timeout.connect(_on_dash_done)
	dash_cd.timeout.connect(func(): dash_ready.emit())
	position_cacher.fill_empty(transform.basis.z * 0.2)

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
	body_vfx.lifetime = lifetime_per_part.sample(parts.size())

	var local_forward = -transform.basis.z.normalized()
	var world_up = (position - world.position).normalized()

	# vertical movement
	var wave_offset = 0
	if !is_dashing():
		wave_timer += delta
		wave_offset = sin(wave_timer * wave_frequency) * height_wave

	position = world.position + world_up * (world.radius + height_offset + wave_offset)

	if is_drifting:
		turbo_energy_accumulated += energy_regen * delta

	if Input.is_action_just_released("drift"):
		turbo_energy_gained = turbo_energy_accumulated
		turbo_energy_accumulated = 0

	if turbo_energy_gained > 0:
		turbo_energy_gained -= energy_drain * delta

	if not is_dashing():	
		var rotation = _rotation_mov(world_up, delta)

	_horizontal_mov(delta)

	if Input.is_action_just_released("drift"):
		curr_speed = curr_speed.normalized() * target_speed.length()

	if (Input.is_action_pressed("dash") and dash_cd.is_stopped() and not is_dashing()):
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

	target_speed = forward * speed_magnitude


	curr_speed = lerp(target_speed, curr_speed, speed_lerp) 
	move_and_collide(curr_speed * delta)
	pass

func spawn_new_part():
	var new_part = s_snake_part.instantiate()
	if new_part is SnakePart:
		var snake_part: SnakePart = new_part
		if parts.size() == 0:
			snake_part.parent_pos_cacher = position_cacher 
		else:
			snake_part.parent_pos_cacher = parts[-1].pos_cacher 
		parts.push_back(snake_part)
		get_parent().add_child.call_deferred(snake_part)
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
	pass

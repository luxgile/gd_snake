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
@export var drift_speed: float
@export var drift_rot: float

var parts: Array[SnakePart] = []
var curr_speed: Vector3
var target_speed: Vector3
var wave_timer: float

func is_dashing(): return not dash_dur.is_stopped()
func dash_in_cd(): return not dash_cd.is_stopped()

func _ready() -> void:
	dash_dur.timeout.connect(_on_dash_done)
	position_cacher.fill_empty(transform.basis.z * 0.2)

	for i in starting_parts:
		spawn_new_part()
	pass

func _on_dash_done():
	dash_cd.start()
	position_cacher.process_mode = Node.PROCESS_MODE_PAUSABLE
	snake_head.visible = true
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
	# var timer_ntime = jump_timer.time_left / jump_timer.wait_time
	# var jump_offset = jump_curve.sample(timer_ntime)
	position = world.position + world_up * (world.radius + height_offset + wave_offset)

	if not is_dashing():	
		_rotation_mov(world_up, delta)
	_horizontal_mov(delta)

	if (Input.is_action_pressed("jump") and dash_cd.is_stopped() and not is_dashing()):
		dash_dur.start()
		position_cacher.process_mode = Node.PROCESS_MODE_DISABLED
		snake_head.visible = false

	# Rotate head to always orbit around planet
	local_forward = world_up.cross(transform.basis.x)
	var target = position + local_forward 
	look_at(target, world_up)
	pass

func _rotation_mov(world_up: Vector3, delta: float) -> void:
	var delta_rotation = 0
	if Input.is_action_pressed("rotate_left"):
		delta_rotation += rot_speed
	if Input.is_action_pressed("rotate_right"):
		delta_rotation -= rot_speed
	rotate(world_up, delta_rotation * delta)
	pass


func _horizontal_mov(delta: float) -> void:
	var forward = TUtils.forward(transform)
	target_speed = forward * normal_speed
	if is_dashing():
		target_speed = forward * dash_speed
	else:
		if Input.is_action_pressed("brake"):
			target_speed = forward * brake_speed
		elif Input.is_action_pressed("accelerate"):
			target_speed = forward * acc_speed

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

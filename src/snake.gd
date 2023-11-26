extends CharacterBody3D
class_name Snake

@export_group("References")
@export var s_snake_part: PackedScene
@export var world: World 
@export var body_vfx: GPUParticles3D
@export var position_cacher: PositionCacher

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

@export_subgroup("Jump")
@export var jump_curve: Curve
@export var jump_timer: Timer

@export_subgroup("Drifting")
@export var drift_speed: float
@export var drift_rot: float

var parts: Array[SnakePart] = []
var curr_speed: Vector3
var target_speed: Vector3
var wave_timer: float
var is_jumping: bool

func _ready() -> void:
	jump_timer.timeout.connect(func(): is_jumping = false)
	position_cacher.fill_empty(transform.basis.z * 0.2)

	for i in starting_parts:
		spawn_new_part()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	body_vfx.lifetime = lifetime_per_part.sample(parts.size())

	var world_up = (position - world.position).normalized()
	var local_forward = -transform.basis.z.normalized()

	if (Input.is_action_pressed("jump") and !is_jumping):
		is_jumping = true
		jump_timer.start()

	# vertical movement
	var wave_offset = 0
	if !is_jumping:
		wave_timer += delta
		wave_offset = sin(wave_timer * wave_frequency) * height_wave
	var timer_ntime = jump_timer.time_left / jump_timer.wait_time
	var jump_offset = jump_curve.sample(timer_ntime)
	position = world.position + world_up * (world.radius + height_offset + wave_offset + jump_offset)

	_rotation_mov(world_up, delta)
	_horizontal_mov(delta)

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

extends CharacterBody3D
class_name Snake

@export var s_snake_part: PackedScene
@export var starting_parts: int
@export var world: World 
@export var position_cacher: PositionCacher
@export var food_eater: Area3D
@export var height_offset: float
@export var speed: float = 10
@export var rot_speed: float = 1

var parts: Array[SnakePart] = []

func _ready() -> void:
	position_cacher.fill_empty(transform.basis.z * 0.2)

	for i in starting_parts:
		spawn_new_part()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var world_up = (position - world.position).normalized()
	var local_forward = -transform.basis.z.normalized()

	# Snap position to world height
	position = world.position + world_up * (world.radius + height_offset)

	_rotation_mov(world_up, delta)
	_horizontal_mov(local_forward, delta)

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


func _horizontal_mov(local_forward: Vector3, delta: float) -> void:
	move_and_collide(local_forward * speed * delta)
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
	pass

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
	var up = (position - world.position).normalized()
	position = world.position + up * (world.radius + height_offset)

	var delta_rotation = 0
	if Input.is_action_pressed("rotate_left"):
		delta_rotation += rot_speed
	if Input.is_action_pressed("rotate_right"):
		delta_rotation -= rot_speed
	rotate(up, delta_rotation * delta)

	var forward = -transform.basis.z.normalized()
	move_and_collide(forward * speed * delta)

	forward = up.cross(transform.basis.x)
	var target = position + forward 
	look_at(target, up)
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

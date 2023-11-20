extends CharacterBody3D

@export var world: World 
@export var height_offset: float
@export var speed: float = 10
@export var rot_speed: float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var up = (position - world.position).normalized()
	position = world.position + up * (world.radius + height_offset)

	var rotation = 0
	if Input.is_action_pressed("rotate_left"):
		rotation += rot_speed
	if Input.is_action_pressed("rotate_right"):
		rotation -= rot_speed
	rotate(up, rotation * delta)

	var forward = -transform.basis.z.normalized()
	move_and_collide(forward * speed * delta)

	forward = up.cross(transform.basis.x)
	var target = position + forward 
	look_at(target, up)
	pass

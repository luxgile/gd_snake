extends Node3D

@export var snake: Snake
@export var curr_speed: RayCast3D
@export var target_speed: RayCast3D


func _process(delta: float) -> void:
	curr_speed.target_position = snake.curr_speed
	target_speed.target_position = snake.target_speed
	pass

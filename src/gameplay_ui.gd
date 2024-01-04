extends Node

@export var parent: Control
@export var glitch_panel: Panel
@export var bar: ProgressBar
@export var exit_time: float = 5
@export var glitch_curve: Curve

var time_pressed: float

func _ready():
	parent.visible = false
	pass

func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return

	if Input.is_action_pressed("exit"):
		parent.visible = true
		time_pressed += delta
	else:
		time_pressed = 0
		parent.visible = false

	var k = pow(time_pressed / exit_time, 1. / 2.5)
	glitch_panel.material.set_shader_parameter("shake_power", glitch_curve.sample(k))
	bar.value = k

	if(k >= 1):
		hub.snake.kill_snake()
		parent.visible = false
	pass

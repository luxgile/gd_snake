extends Node

@export var abort_root: Control
@export var glitch_panel: Panel
@export var bar: ProgressBar
@export var exit_time: float = 5
@export var glitch_curve: Curve
@export var timers_root: Control
@export var death_timer: Label
@export var alive_timer: Label

var time_pressed: float

func _ready():
	abort_root.visible = false
	hub.game_state.state_changed.connect(func(state): timers_root.visible = state == GameState.State.Playing)
	pass

func _process(delta: float) -> void:
	if hub.game_state.current_state != GameState.State.Playing:
		return

	#HACK: Not able to get snake components in any way so I have to rely on their names
	var timer = hub.snake.find_child("death_timer") as SnakeTimer 
	death_timer.text = "%03.1fs" % timer.time
	alive_timer.text = "%03.1fs" % timer.time_alive

	if Input.is_action_pressed("exit"):
		abort_root.visible = true
		time_pressed += delta
	else:
		time_pressed = 0
		abort_root.visible = false

	var k = pow(time_pressed / exit_time, 1. / 2.5)
	glitch_panel.material.set_shader_parameter("shake_power", glitch_curve.sample(k))
	bar.value = k

	if(k >= 1):
		hub.snake.kill_snake()
		abort_root.visible = false
	pass

extends Node3D

@export var start := 0
@export var end := 10
var current := 0

class Twin:
	var timer := 0.
	var duration := 0.
	var callable : Callable
	func _init(dur: float, c: Callable) -> void:
		duration = dur
		callable = c
		pass

	func step(delta: float):
		timer += delta
		callable.call(timer / duration)
		pass

class TwinProxy:
	var twin : Twin
	var start : Variant
	var end : Variant
	var curr : Variant
	func _init(s, e, time : float) -> void:
		start = s
		end = e
		twin = Twin.new(time, func(k): curr = lerp(start, end, k))
		pass

	func step(delta: float):
		twin.step(delta)
		pass

var twin : TwinProxy

func _ready() -> void:
	current = start
	twin = TwinProxy.new(Vector3.ZERO, Vector3.ONE * 100, 10.)
	pass

func _process(delta: float) -> void:
	twin.step(delta)
	position = twin.curr
	pass

extends Node
class_name StatsUI

@export var root: Control
@export var confirm_button: Button
@export var time_played: RichTextLabel
@export var times_played: RichTextLabel
@export var food_eaten: RichTextLabel
@export var dashes: RichTextLabel
@export var best_alive: RichTextLabel
@export var best_length: RichTextLabel
@export var best_combo: RichTextLabel

func _ready() -> void:
	hub.stats_ui = self
	root.visible = false
	pass

func show_stats(): 
	root.visible = true
	var prev_stats = hub.stats.prev_data
	var stats = hub.stats.data	
	var mins_played := roundi(stats.time_played / 60.)
	var hours_played := mins_played / 60
	mins_played = mins_played % 60
	time_played.text = "[b]Time played (h)[/b] - %02d:%02d" % [hours_played, mins_played]
	times_played.text = "[b]Games started[/b] - %d" % stats.times_played
	food_eaten.text = "[b]Food eaten[/b] - %d [color=yellow](+%d)[/color]" % [stats.times_eaten, stats.times_eaten - prev_stats.times_eaten]
	dashes.text = "[b]Dashes[/b] - %d [color=yellow](+%d)[/color]" % [stats.times_dashed, stats.times_dashed - prev_stats.times_dashed]

	var secs_alive := roundi(stats.best_time)
	var mins_alive := secs_alive / 60
	secs_alive = secs_alive % 60
	best_alive.text = "[b]Record alive (m)[/b] - %02d:%02d" % [mins_alive, secs_alive] 
	best_length.text = "[b]Record length[/b] - [color=yellow]%s[/color] %d" % ["NEW" if prev_stats.best_length != stats.best_length else "", stats.best_length]
	best_combo.text = "[b]Record combo[/b] - [color=yellow]%s[/color] %d" % ["NEW" if prev_stats.best_length != stats.best_length else "", stats.best_combo]
	await confirm_button.pressed
	root.visible = false
	pass

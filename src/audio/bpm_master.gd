extends Node
class_name BpmMaster

@export var song: BpmSong
@export var audio_player: AudioStreamPlayer

signal new_beat(int)

var beat_per_second: float
var timer: float
var beat_count: int
var prev_beat: int

func _init() -> void:
	hub.bpm_master = self
	pass

func _ready() -> void:
	play(song)
	pass

func _process(delta: float) -> void:
	var play_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	play_time -= AudioServer.get_output_latency()
	var beat = roundf(play_time / beat_per_second)
	if beat != prev_beat:
		new_beat.emit(beat)
		prev_beat = beat
	pass

func play(bpm_song: BpmSong) -> void:
	song = bpm_song
	audio_player.stream = bpm_song.song
	audio_player.play()
	beat_per_second = (60.0 / bpm_song.bpm )
	pass

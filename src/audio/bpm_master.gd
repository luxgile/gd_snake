extends Node
class_name BpmMaster

@export var song: BpmSong
@export var audio_player: AudioStreamPlayer
@export var start_on_play: bool

signal new_beat(int)

var is_playing: bool
var beat_per_second: float
var timer: float
var beat_count: int
var prev_beat: int


func _init() -> void:
	hub.bpm_master = self
	pass


func _ready() -> void:
	if start_on_play:
		play(song)
	pass


func _process(delta: float) -> void:
	if not is_playing:
		return

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
	beat_per_second = (60.0 / bpm_song.bpm)
	is_playing = true
	pass

func stop():
	audio_player.stop()
	is_playing = false
	pass

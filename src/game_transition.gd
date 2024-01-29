extends Node
class_name GameTransition

@export var s_player: PackedScene
@export var player_parent: Node
@export var glitch_panel: Panel
@export var spawn_dir: Vector3
@export var world: World
@export var camera: SnakeCamera
@export var playing_song: Array[BpmSong]
@export var menu_song: BpmSong

func _init() -> void:
	hub.game_transition = self
	pass

func _ready():
	hub.bpm_master.song_done.connect(_on_song_done)
	hub.bpm_master.play(menu_song)
	pass

func _on_song_done():
	if hub.game_state.current_state == GameState.State.Menu:
		hub.bpm_master.play(menu_song)
	elif hub.game_state.current_state == GameState.State.Playing:
		hub.bpm_master.play(playing_song.pick_random())
	pass

func start_game():
	var game_state = hub.game_state
	if game_state.current_state == GameState.State.Menu:
		game_state.change_state(GameState.State.Transition)
		hub.bpm_master.stop()
		await get_tree().create_timer(2.0).timeout

		hub.bpm_master.play(playing_song.pick_random())

		await hub.bpm_master.new_beat
		hub.world.spawn_planet()

		await hub.bpm_master.new_beat
		glitch_panel.visible = true
		_spawn_player()
		camera.change_state(GameState.State.Playing)

		await hub.bpm_master.new_beat
		glitch_panel.visible = false
		hub.snake.spawn_anim()

		await hub.bpm_master.new_beat
		game_state.change_state(GameState.State.Playing)
	pass

func end_game():
	var game_state = hub.game_state
	if game_state.current_state == GameState.State.Playing:
		game_state.change_state(GameState.State.Transition)
		hub.bpm_master.play(menu_song)

		await hub.bpm_master.new_beat
		hub.world.despawn_planet()

		await hub.bpm_master.new_beat
		_despawn_player()
		camera.change_state(GameState.State.Menu)

		# await hub.bpm_master.new_beat
		# hub.snake.spawn_anim()

		await hub.bpm_master.new_beat
		game_state.change_state(GameState.State.Menu)
	pass

func _spawn_player():
	var player_node = s_player.instantiate()
	if player_node is Snake:
		var snake: Snake = player_node
		snake.position = spawn_dir.normalized() * (world.radius + snake.height_offset)
		player_parent.add_child(snake)
	pass

func _despawn_player():
	hub.snake.queue_free()
	pass

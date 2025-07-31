extends Node

const MUSIC_PLAYER = preload("res://prefabs/game_music_player.tscn");

#region Audio Imports
const BUTTON_A = preload("res://assets/audio/sfx/button/button_A.ogg")
const BUTTON_CLICK_A = preload("res://assets/audio/sfx/button/button_click_A.ogg")

const IGNITE = preload("res://assets/audio/sfx/stovetop/ignite.ogg");
const SIZZLE = preload("res://assets/audio/sfx/stovetop/sizzle.ogg");

const SLIME_IMPACT_SLAP = preload("res://assets/audio/sfx/impacts/Slime_impact_slap.ogg");
const FLICK_A_WET = preload("res://assets/audio/sfx/impacts/flick_A_WET.ogg");

const SCORING_NOTE_BLUE = preload("res://assets/audio/sfx/scoring/SCORING_NOTE_BLUE.ogg");
const SCORING_NOTE_RED = preload("res://assets/audio/sfx/scoring/SCORING_NOTE_RED.ogg");
const SCORING_NOTE_YELLOW = preload("res://assets/audio/sfx/scoring/SCORING_NOTE_YELLOW.ogg");

const FOOTSTEP_WOOD_000 = preload("res://assets/audio/sfx/impacts/footstep_wood_000.ogg");
const FOOTSTEP_WOOD_001 = preload("res://assets/audio/sfx/impacts/footstep_wood_001.ogg");
const FOOTSTEP_WOOD_002 = preload("res://assets/audio/sfx/impacts/footstep_wood_002.ogg");
const FOOTSTEP_WOOD_003 = preload("res://assets/audio/sfx/impacts/footstep_wood_003.ogg");
const FOOTSTEP_WOOD_004 = preload("res://assets/audio/sfx/impacts/footstep_wood_004.ogg");

const FOOTSTEP_GRASS_001 = preload("res://assets/audio/sfx/impacts/footstep_grass_001.ogg");
const FOOTSTEP_GRASS_002 = preload("res://assets/audio/sfx/impacts/footstep_grass_002.ogg");
const FOOTSTEP_GRASS_003 = preload("res://assets/audio/sfx/impacts/footstep_grass_003.ogg");
const FOOTSTEP_GRASS_004 = preload("res://assets/audio/sfx/impacts/footstep_grass_004.ogg");

const SLIME_A_IMPACT_A = preload("res://assets/audio/sfx/impacts/Slime_A_Impact_A.ogg");
const SLIME_A_IMPACT_B = preload("res://assets/audio/sfx/impacts/Slime_A_Impact_B.ogg");
const SLIME_A_IMPACT_C = preload("res://assets/audio/sfx/impacts/Slime_A_Impact_C.ogg");
const SLIME_A_IMPACT_D = preload("res://assets/audio/sfx/impacts/Slime_A_Impact_D.ogg");

const EGG_IMPACT = preload("res://assets/audio/sfx/impacts/egg-impact.ogg");

const CRASH_1 = preload("res://assets/audio/sfx/percussion/crash-1.ogg");
const CYMBAL_1 = preload("res://assets/audio/sfx/percussion/cymbal-1.ogg");
const HIHAT_1 = preload("res://assets/audio/sfx/percussion/hihat-1.ogg");
const HIHAT_2 = preload("res://assets/audio/sfx/percussion/hihat-2.ogg");
const HIHAT_3 = preload("res://assets/audio/sfx/percussion/hihat-3.ogg");
const HIHAT_OPEN_1 = preload("res://assets/audio/sfx/percussion/hihat-open-1.ogg");
const KICK_1 = preload("res://assets/audio/sfx/percussion/kick-1.ogg");
const RIDE_1 = preload("res://assets/audio/sfx/percussion/ride-1.ogg");
const RIDE_2 = preload("res://assets/audio/sfx/percussion/ride-2.ogg");
const RIDE_3 = preload("res://assets/audio/sfx/percussion/ride-3.ogg");
const SNARE_1 = preload("res://assets/audio/sfx/percussion/snare-1.ogg");
const SNARE_2 = preload("res://assets/audio/sfx/percussion/snare-2.ogg");
const THONK_1 = preload("res://assets/audio/sfx/percussion/thonk-1.ogg");
#endregion

#region Bundled Audio
const OOF: Array[AudioStream] = [
	SLIME_A_IMPACT_A,
	SLIME_A_IMPACT_B,
	SLIME_A_IMPACT_C,
	SLIME_A_IMPACT_D,
];

const IMPACT_SOFT: Array[AudioStream] = [
	FOOTSTEP_WOOD_000,
	FOOTSTEP_WOOD_001,
	FOOTSTEP_WOOD_002,
	FOOTSTEP_WOOD_003,
	FOOTSTEP_WOOD_004,
];

const IMPACT_HARD: Array[AudioStream] = [
	FOOTSTEP_GRASS_001,
	FOOTSTEP_GRASS_002,
	FOOTSTEP_GRASS_003,
	FOOTSTEP_GRASS_004,
];

const SCORING: Array[AudioStream] = [
	SCORING_NOTE_BLUE,
	SCORING_NOTE_RED,
	SCORING_NOTE_YELLOW,
];

const MENU_PERCUSSION: Array[AudioStream] = [
	HIHAT_1,
	HIHAT_3,
	HIHAT_OPEN_1,
	SNARE_1,
	SNARE_2,
];
#endregion


var music_volume: float = 0.5;
var sfx_volume: float = 0.5;

var menu_music_player: AudioStreamPlayer;
var game_music_player: AudioStreamPlayer;

var current_player: AudioStreamPlayer = null;
var tween: Tween;

func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_added);

func _ready() -> void:
	game_music_player = MUSIC_PLAYER.instantiate() as AudioStreamPlayer;
	game_music_player.bus = "Music";
	
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	add_child(game_music_player);
	game_music_player.play();

func initialize_player(stream: Resource) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new();
	player.bus = "Music";
	player.stream = stream;
	player.volume_db = -72;
	player.autoplay = true;
	#player.stream_paused = true
	add_child(player);
	return player;

func crossfade(new_player: AudioStreamPlayer, fade_in_t: float = 1, fade_out_t: float = 1) -> void:
	# Accept a new music player to start playing
	# Fade out the current player
	# Fade in the new player
	if new_player == current_player: return;
	tween = get_tree().create_tween().set_parallel();
	#new_player.stream_paused = false
	tween.tween_property(current_player, "volume_db", -72, fade_out_t);
	tween.tween_property(new_player, "volume_db", 0, fade_in_t);
	await tween.finished;
	current_player = new_player;
	#current_player.stream_paused = true

func play(player: AudioStreamPlayer, fade_in_t: float = 1) -> void:
	# Start an existing audio player
	# Does not add to or overwrite the main 'current player'
	# Only meant to play atop existing elements.
	var play_tween = get_tree().create_tween();
	#player.stream_paused = false
	play_tween.tween_property(player, "volume_db", 0, fade_in_t);

func stop(player: AudioStreamPlayer, fade_out_t: float = 1) -> void:
	# Stop a specific existing audio player
	var stop_tween = get_tree().create_tween();
	stop_tween.tween_property(player, "volume_db", -72, fade_out_t);
	await stop_tween.finished;
	#player.stream_paused = true

func set_volume(mixer: String, volume: float) -> float:
	var bus_idx = AudioServer.get_bus_index(mixer);
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume));
	return volume;

func play_audio(file: AudioStream, mixer: String = "SFX", volume: float = 1) -> void:
	# given a preloaded soundfile, generate an audio stream player, spawn it
	# load the file, play it, and then destroy the player.
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new();
	audio_player.stream = file;
	audio_player.bus = mixer;
	audio_player.volume_db = linear_to_db(volume);
	add_child(audio_player);
	audio_player.play();
	await audio_player.finished;
	remove_child(audio_player);
	audio_player.queue_free();

func play_random(list: Array[AudioStream], player: AudioStreamPlayer3D = null) -> void:
	var track = list.pick_random();
	if player:
		player.stream = track;
		player.play();
	else:
		play_audio(track);

func fade_track(idx, vol, t) -> void:
	var cur_vol = game_music_player.stream.get_sync_stream_volume(idx);
	var callback = func(value): game_music_player.stream.set_sync_stream_volume(idx, value);
	var tween_2 = get_tree().create_tween();
	tween_2.tween_method(callback, cur_vol, vol, t);

# Set up button SFX for clicks and hovers automatically.
func on_node_added(node: Node) -> void:
	if node is Button:
		node.mouse_entered.connect(on_button_hover);
		node.pressed.connect(on_button_pressed);

func on_button_hover() -> void:
	#AudioManager.play_random(AudioManager.MENU_PERCUSSION);
	pass;

func on_button_pressed() -> void:
	AudioManager.play_random(AudioManager.MENU_PERCUSSION);

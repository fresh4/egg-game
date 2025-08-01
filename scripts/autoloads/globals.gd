extends Node

## This autoload script holds variables and functions useful for all scripts. 

var is_look_inverted: bool = false;

var is_game_started: bool = false :
	get:
		return is_game_started;
	set(value):
		is_game_started = value;
		if value: SignalBus.game_started.emit();

var camera_sensitivity_setting: float = 1;

var has_played_cutscene = false;

var is_cutscene_playing: bool = false;

## Function that 'stops' time for a very brief moment.
## Timescale is how slow you want the game to run (0.5 for half speed etc)
## Duration is how long you want it to remain that way
## Note that timescale must be > 0, as time will never resume if the engine has stopped counting
func freeze_frame(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale;
	await get_tree().create_timer(duration * timescale).timeout;
	Engine.time_scale = 1.0;

func add_points(value: int) -> void:
	var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager");
	game_manager.points += value;

func get_points() -> int:
	var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager");
	return game_manager.points;

#func end_game() -> void:
	#is_game_started = false;
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	#SignalBus.game_ended.emit()
#
#func start_game() -> void:
	#is_game_started = true;
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	#SignalBus.game_started.emit()

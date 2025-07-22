extends Node

var is_look_inverted: bool = false;

var is_game_started: bool = false :
	get:
		return is_game_started;
	set(value):
		is_game_started = value;
		if value: SignalBus.game_started.emit();

var camera_sensitivity_setting: float = 1;

var has_played_cutscene = false;

#func end_game() -> void:
	#is_game_started = false;
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	#SignalBus.game_ended.emit()
#
#func start_game() -> void:
	#is_game_started = true;
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	#SignalBus.game_started.emit()

class_name GameManager extends Node

var points: int = 0;
var has_won: bool = false;

func _ready() -> void:
	SignalBus.egg_shattered.connect(on_egg_shattered);

func on_egg_shattered() -> void:
	Globals.is_game_started = false;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	SignalBus.game_ended.emit(has_won, points);

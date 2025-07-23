extends Control

@onready var play_button: Button = %PlayButton;
@onready var settings_button: Button = %SettingsButton;

var ui: UI;

func _ready() -> void:
	ui = get_parent();
	play_button.pressed.connect(on_play_button_pressed);
	settings_button.pressed.connect(on_settings_button_pressed);
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

func on_play_button_pressed() -> void:
	# Start Game
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1);
	await tween.finished;
	start_game();

func on_settings_button_pressed() -> void:
	# Spawn settings page and hide main menu
	visible = false;
	ui.pause();

func start_game() -> void:
	Globals.is_game_started = true;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	queue_free();

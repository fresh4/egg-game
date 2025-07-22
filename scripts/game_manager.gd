class_name GameManager extends Node

var player: Player;
var camera: Camera3D;
var points: int = 0;
var has_won: bool = false;

@onready var intro_cutscene: AnimationPlayer = %IntroCutscene;

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player");
	camera = player.camera;
	SignalBus.egg_shattered.connect(on_egg_shattered);
	SignalBus.game_started.connect(on_game_started);

func on_egg_shattered() -> void:
	Globals.is_game_started = false;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	SignalBus.game_ended.emit(has_won, points);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and intro_cutscene.is_playing():
		intro_cutscene.advance(intro_cutscene.current_animation_length - intro_cutscene.current_animation_position);

# Play the intro cutscene on first time playing.
func on_game_started() -> void:
	if !Globals.has_played_cutscene:
		Globals.is_game_started = false;
		intro_cutscene.play("pan_to_stove");
		await intro_cutscene.animation_finished;
		Globals.has_played_cutscene = true;
		Globals.is_game_started = true;

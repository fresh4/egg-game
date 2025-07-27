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
	if !Globals.has_played_cutscene:
		intro_cutscene.play("open_fridge");
		intro_cutscene.advance(0.0);
		intro_cutscene.pause();
	if Globals.is_game_started:
		on_game_started();

func on_egg_shattered() -> void:
	Globals.is_game_started = false;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	SignalBus.game_ended.emit(has_won, points);

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and Globals.is_game_started:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	if event.is_action_pressed("jump") and intro_cutscene.is_playing():
		intro_cutscene.advance(intro_cutscene.current_animation_length - intro_cutscene.current_animation_position);

# Play the intro cutscene on first time playing.
func on_game_started() -> void:
	if !Globals.has_played_cutscene:
		Globals.is_cutscene_playing = true;
		intro_cutscene.play("open_fridge");
		await intro_cutscene.animation_finished;
		intro_cutscene.play("pan_to_stove");
		await intro_cutscene.animation_finished;
		Globals.has_played_cutscene = true;
		Globals.is_cutscene_playing = false;
	else:
		intro_cutscene.play("pan_to_stove");
		intro_cutscene.advance(intro_cutscene.current_animation_length);

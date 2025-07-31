class_name UI extends CanvasLayer

const START_MENU = preload("res://prefabs/ui/start_menu/start_menu.tscn");
const SETTINGS = preload("res://prefabs/ui/settings/settings_menu.tscn");
const END = preload("res://prefabs/ui/end/end_menu.tscn");

var settings_scene: Control;
var start_menu: Control;

@onready var points_label: Label = %PointsLabel;

func _ready() -> void:
	start_menu = instance_scene(START_MENU);
	start_menu.visible = true;
	settings_scene = instance_scene(SETTINGS);
	instance_scene(END);
	
	points_label.text = "0";
	if !Globals.is_game_started:
		points_label.visible = false;
	
	SignalBus.points_updated.connect(on_points_updated);
	SignalBus.game_started.connect(func(): points_label.visible = true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and Globals.is_game_started:
		if get_tree().paused:
			await unpause();
		else:
			pause();

func pause() -> void:
	get_tree().paused = true;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	settings_scene.visible = true;
	
	settings_scene.modulate.a = 0;
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(settings_scene, "modulate", Color(1,1,1,1), 0.25);
	if Globals.is_game_started:
		AudioServer.set_bus_effect_enabled(1, 0, true); # TODO: Use enums or gets

func unpause() -> void:
	get_tree().paused = false;
	
	settings_scene.modulate.a = 1;
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(settings_scene, "modulate", Color(1,1,1,0), 0.25);
	await tween.finished;
	settings_scene.visible = false;
	
	if !Globals.is_game_started:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		start_menu.visible = true;
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	AudioServer.set_bus_effect_enabled(1, 0, false); # TODO: Use enums or gets

func instance_scene(scene) -> Node:
	var instance = scene.instantiate();
	add_child(instance);
	instance.visible = false;
	
	return instance;

func on_points_updated(value: int) -> void:
	points_label.text = str(value);

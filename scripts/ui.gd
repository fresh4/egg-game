class_name UI extends CanvasLayer

const SETTINGS = preload("res://prefabs/ui/settings/settings.tscn");
const VICTORY = preload("res://prefabs/ui/victory/victory.tscn");

var settings_scene: Control;

func _ready() -> void:
	settings_scene = SETTINGS.instantiate();
	add_child(settings_scene);
	settings_scene.visible = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and Globals.is_game_started:
		@warning_ignore("standalone_ternary")
		pause() if !get_tree().paused else await unpause();

func pause() -> void:
	get_tree().paused = true;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	settings_scene.visible = true;
	
	settings_scene.modulate.a = 0;
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(settings_scene, "modulate", Color(1,1,1,1), 0.25);

func unpause() -> void:
	get_tree().paused = false;
	
	settings_scene.modulate.a = 1;
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(settings_scene, "modulate", Color(1,1,1,0), 0.25);
	await tween.finished;
	settings_scene.visible = false;
	
	if !Globals.is_game_started:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		$StartMenu.visible = true;
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

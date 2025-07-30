extends AnimationPlayer

func _ready() -> void:
	SignalBus.game_started.connect(on_game_started);
	if !Globals.has_played_cutscene:
		play("open_fridge");
		advance(0.0);
		pause();
	if Globals.is_game_started:
		on_game_started();

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and Globals.is_game_started:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	if event.is_action_pressed("jump") and is_playing():
		advance(current_animation_length - current_animation_position);

func on_game_started() -> void:
	if !Globals.has_played_cutscene:
		Globals.is_cutscene_playing = true;
		play("open_fridge");
		await animation_finished;
		play("pan_to_stove");
		await animation_finished;
		Globals.is_cutscene_playing = false;
		Globals.has_played_cutscene = true;
	else:
		play("pan_to_stove");
		advance(current_animation_length);

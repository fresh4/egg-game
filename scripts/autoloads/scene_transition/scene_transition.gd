extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func change_scene(target: String = "") -> void:
	animation_player.play("transition_in");
	await animation_player.animation_finished;
	if target == "":
		get_tree().reload_current_scene();
	else:
		get_tree().change_scene_to_file(target);
	await get_tree().create_timer(0.25).timeout;
	animation_player.play_backwards("transition_in");

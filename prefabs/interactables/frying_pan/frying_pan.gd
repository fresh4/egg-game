extends StaticBody3D

@onready var victory_detection_area: Area3D = %VictoryDetectionArea;
@onready var egg: MeshInstance3D = %egg;

func _ready() -> void:
	victory_detection_area.body_entered.connect(on_victory_detection_area_entered);
	egg.visible = false;

func on_victory_detection_area_entered(body: Node3D) -> void:
	if !(body is Player): return;
	var player: Player = body as Player;
	var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager");
	
	egg.visible = true;
	game_manager.has_won = true;
	player.shatter_egg();
	
	AudioManager.play_audio(AudioManager.SIZZLE);

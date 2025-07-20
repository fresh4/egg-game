class_name GameManager extends Node

var player: Player;
var camera: Camera3D;
var points: int = 0;

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player");
	camera = player.camera;
	SignalBus.egg_shattered.connect(on_egg_shattered);

func on_egg_shattered() -> void:
	# TODO: Maybe move this into the UI script?
	Globals.is_game_started = false;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	SignalBus.game_ended.emit(false, points);

# TODO: Either here, or in a UI menu node, camera start in position
# overlooking the kitchen. On "play", transition camera (with animationplayer)
# to initial position.

extends Node

var player: Player
var camera: Camera3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player");
	camera = player.camera;

# TODO: Either here, or in a UI menu node, camera start in position
# overlooking the kitchen. On "play", transition camera (with animationplayer)
# to initial position.

extends RigidBody3D

var player: Player;

func _ready() -> void:
	player = get_parent();

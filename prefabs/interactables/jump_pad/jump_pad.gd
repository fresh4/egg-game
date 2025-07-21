extends StaticBody3D

const BOUNCE_POWER: float = 1.0;

@onready var player_detection_area: Area3D = %PlayerDetectionArea

func _ready() -> void:
	player_detection_area.body_entered.connect(on_player_impact);

func on_player_impact(body: RigidBody3D) -> void:
	body.apply_central_impulse(Vector3(0,1,0) * BOUNCE_POWER);

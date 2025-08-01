extends StaticBody3D

@export_range(0, 1.5) var BOUNCE_POWER: float = 1.0;
@export var predefined_vector: Vector2 = Vector2.ZERO;

@onready var player_detection_area: Area3D = %PlayerDetectionArea;
@onready var animation_player: AnimationPlayer = %AnimationPlayer;

func _ready() -> void:
	player_detection_area.body_entered.connect(on_player_impact);

func on_player_impact(body: RigidBody3D) -> void:
	if !(body is Player): return;
	(body as Player).is_jumping = true;
	body.linear_velocity.y = 0;
	if (predefined_vector.x or predefined_vector.y):
		body.linear_velocity.x = predefined_vector.x;
		body.linear_velocity.z = predefined_vector.y;
	body.apply_central_impulse(Vector3(0,1,0) * BOUNCE_POWER);
	animation_player.play("wobble");
	AudioManager.play_audio(AudioManager.FLICK_A_WET);

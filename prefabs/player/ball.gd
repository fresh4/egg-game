extends RigidBody3D

var player: Player;

func _ready() -> void:
	player = get_parent();

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	# Limit ball velocities.
	linear_velocity.x = clampf(linear_velocity.x, -player.MAX_SPEED, player.MAX_SPEED);
	linear_velocity.y = clampf(linear_velocity.y, -50, 50);
	linear_velocity.z = clampf(linear_velocity.z, -player.MAX_SPEED, player.MAX_SPEED);
	angular_velocity.x = clampf(angular_velocity.x, -player.MAX_SPEED, player.MAX_SPEED);
	angular_velocity.y = clampf(angular_velocity.y, -player.MAX_SPEED, player.MAX_SPEED);
	angular_velocity.z = clampf(angular_velocity.z, -player.MAX_SPEED, player.MAX_SPEED);

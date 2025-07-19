class_name Player extends Node3D

const SPLAT = preload("res://prefabs/splat.tscn");

@export var MAX_SPEED: int = 25; ## Maximum allowed speed (linear or angular).
@export var ACC_RATE: float = 0.001; ## The rate at which ball will speed up.
@export var STRAFE_MULTIPLIER: float = 1; ## Speed multiplier for left/right movement.
@export var BASE_FOV: float = 75.0; ## Default camera FOV.
@export var MAX_FOV: float = 110.0; ## Maximum allowed camera FOV.
@export var SHATTER_THRESHOLD: float = 6.0;
@export var MAX_HEALTH: int = 3;

@onready var camera_pivot: Node3D = %CameraPivot;
@onready var camera: Camera3D = %Camera;
@onready var ball: RigidBody3D = %Ball;

var health: int 
var forward: Vector3 = Vector3.ZERO; ## The calculated forward direction, based on direction of camera.
var default_camera_orientation: Vector3;
var last_frames_velocity: Vector3 = Vector3.ZERO;
var splat_scene: DecalCompatibility;

func _ready() -> void:
	health = MAX_HEALTH;
	camera.fov = BASE_FOV;
	default_camera_orientation = camera_pivot.rotation;
	ball.body_entered.connect(_on_hit_ground);

func _process(_delta: float) -> void:
	# Reset camera's (parent) position to follow ball.
	camera_pivot.global_position = ball.global_position;

func _physics_process(_delta: float) -> void:
	# Store the previous frame's velocity for calulating velocity on impacts.
	last_frames_velocity = ball.linear_velocity;
	
	# Set "forward" to be direction camera is facing.
	forward = camera.global_transform.basis.z.normalized().cross(Vector3.UP);
	
	# Limit ball velocities.
	ball.linear_velocity.x = clampf(ball.linear_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.y = clampf(ball.linear_velocity.y, -50, 50);
	ball.linear_velocity.z = clampf(ball.linear_velocity.z, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.x = clampf(ball.angular_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.y = clampf(ball.angular_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.z = clampf(ball.angular_velocity.z, -MAX_SPEED, MAX_SPEED);
	handle_input();
	
	if ball.global_position.y < -40: ball.global_position = Vector3(0, 10, 0);

func _input(event: InputEvent) -> void:
	#if not Globals.is_game_started: return;
	
	# If key is tapped, not held, reset camera rotation.
	if Input.is_action_just_pressed("rotate_camera"):
		await get_tree().create_timer(0.15).timeout;
		if not Input.is_action_pressed("rotate_camera"):
			reset_camera();
	
	# Rotate the camera if key is held and mouse is in motion.
	if event is InputEventMouseMotion:
		var invert = 1 if Globals.is_look_inverted else -1;
		camera_pivot.rotation.x += invert * event.relative.y * 0.01 * Globals.camera_sensitivity_setting; 
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -deg_to_rad(75), deg_to_rad(0));
		camera_pivot.rotation.y += invert * event.relative.x * 0.01 * Globals.camera_sensitivity_setting;
		camera_pivot.rotation.z = 0;

func move(dir) -> void:
	# Push the ball by applying torque along a direction at a passed in rate.
	ball.apply_torque_impulse(dir * ACC_RATE);
	
	# Change the FOV of the camera based on the speed of the ball.
	var new_fov = clampf(calculate_fov(), BASE_FOV, MAX_FOV);
	var tween = get_tree().create_tween();
	tween.tween_property(camera, "fov", new_fov, 0.15);

## Helper function to calculate FOV based on current speed limitation variables.
func calculate_fov() -> float:
	return BASE_FOV + ( MAX_FOV - BASE_FOV ) * ( ball.linear_velocity.length() / 30 );

func handle_input() -> void:
	if Input.is_action_pressed("forward"):
		move(forward);
	if Input.is_action_pressed("backward"):
		move(-forward);
	if Input.is_action_pressed("left"):
		move(-forward.cross(Vector3.UP) * STRAFE_MULTIPLIER);
	if Input.is_action_pressed("right"):
		move(forward.cross(Vector3.UP) * STRAFE_MULTIPLIER);

## Helper function to reset camera orientation.
func reset_camera() -> void:
	var tween = get_tree().create_tween();
	tween.tween_property(camera_pivot, "rotation", default_camera_orientation, 0.15);

func _on_hit_ground(_body: Node3D) -> void:
	#print(ball.linear_velocity.length(), " ", last_frames_velocity.length())
	if abs(last_frames_velocity.length()) - abs(ball.linear_velocity.length()) > 1:
		health = clamp(health - 1, 0, MAX_HEALTH);
		splat_scene = SPLAT.instantiate();
		get_parent().add_child(splat_scene);
		splat_scene.enable_fade = false;
		splat_scene.global_position = ball.global_position;
		splat_scene.rotation_degrees = Vector3(-24, 0, 24);
		
		print("splat")

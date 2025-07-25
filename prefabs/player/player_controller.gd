class_name Player extends Node3D

const SPLAT = preload("res://prefabs/splat.tscn");

@export var CRACK_TEXTURES: Array[CompressedTexture2D]; ## List of textures to use for the cracked egg.
@export var SHATTERED_EGG: PackedScene; ## Scene containing the fragmented egg.
@export var MAX_SPEED: int = 25; ## Maximum allowed speed (linear or angular).
@export var ACC_RATE: float = 1.5; ## The rate at which ball will speed up.
@export var STRAFE_MULTIPLIER: float = 1.25; ## Speed multiplier for left/right movement.
@export var BASE_FOV: float = 75.0; ## Default camera FOV.
@export var MAX_FOV: float = 110.0; ## Maximum allowed camera FOV.
@export var SHATTER_THRESHOLD: float = 6.0; ## How hard of an impact to trigger a crack.
@export var MAX_HEALTH: int = 3; ## Max number of times you can get hit before dying.
@export_range(0, 1) var JUMP_POWER: float = 0.2; ## How high the player can jump.

@onready var camera_pivot: Node3D = %CameraPivot;
@onready var camera: Camera3D = %Camera;
@onready var ball: RigidBody3D = %Ball;
@onready var animation_player: AnimationPlayer = %AnimationPlayer;
@onready var egg_mesh: MeshInstance3D = %Egg;

var health: int; ## The current health of the egg.
var forward: Vector3 = Vector3.ZERO; ## The calculated forward direction, based on direction of camera.
var is_jumping: bool = false;
var default_camera_orientation: Vector3;
var last_frames_velocity: Vector3 = Vector3.ZERO;
var splat_scene: DecalCompatibility; # WARNING: Compatibility mode limitation; replace with Decal if changing renderers.
var shattered_egg_scene: Node3D; ## Scene object containing the pre-fragmented version of the egg.

func _ready() -> void:
	call_deferred("spawn_fragmented_egg");
	egg_mesh.material_override.set_shader_parameter("base_texture", null);
	
	health = MAX_HEALTH;
	camera.fov = BASE_FOV;
	default_camera_orientation = camera_pivot.rotation;
	ball.body_entered.connect(_on_hit_ground);

func _process(_delta: float) -> void:
	# Reset camera's (parent) position to follow ball.
	camera_pivot.global_position = ball.global_position;

func _physics_process(_delta: float) -> void:
	if not Globals.is_game_started: return;
	if Globals.is_cutscene_playing: return;
	
	# Store the previous frame's velocity for calulating velocity deltas on impacts.
	last_frames_velocity = ball.linear_velocity;
	
	# Set "forward" to be direction camera is facing.
	forward = camera.global_transform.basis.z.normalized().cross(Vector3.UP);
	
	handle_input();
	
	# Reset position if you fall outside the level bounds
	if ball.global_position.y < -40: ball.global_position = Vector3(0, 10, 0);

func _input(event: InputEvent) -> void:
	if not Globals.is_game_started: return;
	if Globals.is_cutscene_playing: return;
	
	# If key is tapped, not held, reset camera rotation.
	if Input.is_action_just_pressed("rotate_camera"):
		await get_tree().create_timer(0.15).timeout;
		if not Input.is_action_pressed("rotate_camera"):
			reset_camera();
	
	# Rotate the camera if mouse is in motion.
	if event is InputEventMouseMotion:
		var invert = 1 if Globals.is_look_inverted else -1;
		camera_pivot.rotation.x += invert * event.relative.y * 0.01 * Globals.camera_sensitivity_setting; 
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -deg_to_rad(75), deg_to_rad(25));
		camera_pivot.rotation.y += invert * event.relative.x * 0.01 * Globals.camera_sensitivity_setting;
		camera_pivot.rotation.z = 0;

func midair_move(dir: Vector3) -> void:
	ball.apply_central_force(dir.cross(Vector3.UP) * ACC_RATE / 20 );

func move(dir: Vector3) -> void:
	if abs(ball.linear_velocity.y) > 1:
		midair_move(dir);
	# Push the ball by applying torque along a direction at a passed in rate.
	ball.apply_torque_impulse(dir * ACC_RATE / 1000);
	
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
	if Input.is_action_pressed("jump") and !is_jumping:
		is_jumping = true;
		ball.apply_central_impulse(Vector3(0,1,0) * JUMP_POWER);
		await get_tree().create_timer(.75).timeout;
		is_jumping = false;

## Helper function to reset camera orientation.
func reset_camera() -> void:
	var tween = get_tree().create_tween();
	tween.tween_property(camera_pivot, "rotation", default_camera_orientation, 0.15);

func _on_hit_ground(body: Node3D) -> void:
	is_jumping = false;
	# Magic number '1' is for environment objects (floors, walls, tables, etc)
	# Check to see if we did indeed hit the ground, not some other object.
	if body is StaticBody3D and !(body as StaticBody3D).collision_layer == 1: return;
	var delta_v = abs(last_frames_velocity.length()) - abs(ball.linear_velocity.length());
	
	if delta_v >= 2:
		shatter_egg();
	elif delta_v > 1:
		animation_player.play("impact");
		health = clamp(health - 1, 0, MAX_HEALTH);
		if len(CRACK_TEXTURES):
			var idx = clamp(MAX_HEALTH - health - 1, 0, len(CRACK_TEXTURES) - 1)
			var texture = CRACK_TEXTURES[idx];
			egg_mesh.material_override.set_shader_parameter("base_texture", texture);
	if health <= 0:
		shatter_egg();

func shatter_egg() -> void:
	visible = false;
	ball.freeze = true;
	shattered_egg_scene.global_position = ball.global_position;
	shattered_egg_scene.visible = true;
	for piece: RigidBody3D in shattered_egg_scene.get_children():
		piece.freeze = false;
		piece.apply_impulse(piece.position * 2);
	SignalBus.egg_shattered.emit();
	draw_splat();
	AudioManager.play_audio(AudioManager.SLIME_IMPACT_SLAP);

func draw_splat() -> void:
	splat_scene.visible = true;
	splat_scene.enable_fade = false;
	splat_scene.global_position = ball.global_position;
	splat_scene.rotation_degrees = Vector3(-24, 0, 24);

func spawn_fragmented_egg() -> void:
	# TODO: Hacky solution to precompile decal shaders, optimize this.
	splat_scene = SPLAT.instantiate();
	get_parent().add_child(splat_scene);
	splat_scene.global_position = ball.global_position;
	await get_tree().create_timer(1).timeout;
	splat_scene.visible = false;
	
	shattered_egg_scene = SHATTERED_EGG.instantiate();
	get_parent().add_child(shattered_egg_scene);
	for body: RigidBody3D in shattered_egg_scene.get_children():
		body.freeze = true;
	shattered_egg_scene.visible = false;

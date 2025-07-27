extends Node3D

@export var points_value: int = 100;

@onready var pickup_detection_area: Area3D = %PickupDetectionArea;

func _ready() -> void:
	pickup_detection_area.body_entered.connect(on_pickup_detection_area_body_entered);

func on_pickup_detection_area_body_entered(_body: Node3D) -> void:
	Globals.add_points(points_value);
	queue_free();

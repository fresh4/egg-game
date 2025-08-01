extends AnimatableBody3D

@onready var detection_area: Area3D = %DetectionArea;

func _ready() -> void:
	detection_area.body_entered.connect(on_body_entered);

func on_body_entered(body: Node3D) -> void:
	if body is not Player: return;
	(body as Player).shatter_egg();

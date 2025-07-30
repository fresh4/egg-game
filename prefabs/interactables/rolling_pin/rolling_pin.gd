extends AnimatableBody3D

@onready var detection_area: Area3D = %DetectionArea;

func _ready() -> void:
	detection_area.body_entered.connect(on_body_entered);

func on_body_entered(body: Node3D) -> void:
	if body.get_parent() is not Player: return;
	(body.get_parent() as Player).shatter_egg();

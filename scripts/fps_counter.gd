extends Label

@export var enabled: bool = false

func _ready() -> void:
	visible = enabled;

func _physics_process(_delta: float) -> void:
	text = str(Engine.get_frames_per_second())

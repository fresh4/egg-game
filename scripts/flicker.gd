extends OmniLight3D
## Script is to be attached to any omnilight.
## When activated (flickering = true), will randomly flicker the birghtness.

@export var flickering: bool = false;

var random_value: float = 0.0;
var timer: Timer;

func _ready() -> void:
	timer = Timer.new();
	timer.one_shot = false;
	timer.autostart = true;
	timer.wait_time = 0.1;
	timer.timeout.connect(_on_timer_timeout);
	add_child(timer);

func _process(_delta: float) -> void:
	if !flickering: return;
	light_energy = lerp(light_energy, random_value, 0.3);

func _on_timer_timeout() -> void:
	random_value = randf_range(0.2, 1);

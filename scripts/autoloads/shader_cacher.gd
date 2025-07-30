extends AnimationPlayer

func _ready() -> void:
	if Globals.has_played_cutscene: return;
	play("cache_materials");

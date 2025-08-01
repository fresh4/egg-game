extends AnimationPlayer

func _ready() -> void:
	# We only want to cache on the first time the game is run.
	# We can track this by checking if the initial cutscene has been played
	# since it should only ever run on first load.
	if Globals.has_played_cutscene: return;
	play("cache_materials");

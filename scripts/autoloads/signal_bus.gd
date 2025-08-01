extends Node

## Standard event/signal bus. Globally accessible signals to access and emit
## from any script without needing each script to know about the other.

@warning_ignore_start("unused_signal")
signal game_started();
signal game_ended(is_win: bool, points: int);
signal egg_shattered();
signal points_updated(value: int);

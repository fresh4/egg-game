extends Control

const FINISHED_BONUS: int = 1000;
const PER_HP_BONUS: int = 250;

@onready var message_label: Label = %MessageLabel;
@onready var bonuses_label: Label = %BonusesLabel
@onready var points_label: Label = %PointsLabel;
@onready var restart_button: Button = %RestartButton;

var victory_message: String = "Eggcelent!";
var defeat_message: String = "Eggspired";
var player: Player;

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player");
	visible = false;
	message_label.visible = false;
	bonuses_label.visible = false;
	points_label.visible = false;
	restart_button.visible = false;
	
	restart_button.pressed.connect(on_restart_button_pressed);
	SignalBus.game_ended.connect(on_game_ended);

func on_restart_button_pressed() -> void:
	SceneTransition.change_scene();

func on_game_ended(is_won: bool, points: int) -> void:
	message_label.text = victory_message if is_won else defeat_message;
	
	await get_tree().create_timer(1).timeout;
	visible = true;
	
	await get_tree().create_timer(0.25).timeout;
	message_label.visible = true;
	AudioManager.play_audio(AudioManager.SCORING_NOTE_YELLOW);
	
	if is_won:
		bonuses_label.visible = true;
		await get_tree().create_timer(0.25).timeout;
		
		bonuses_label.text = "Lives x" + str(player.health) + ": " + str(player.health * PER_HP_BONUS);
		AudioManager.play_audio(AudioManager.SLIME_IMPACT_SLAP);
		await get_tree().create_timer(0.25).timeout;
		
		bonuses_label.text += "\nFinished: " + str(FINISHED_BONUS);
		AudioManager.play_audio(AudioManager.SLIME_IMPACT_SLAP);
		await get_tree().create_timer(0.25).timeout;
		
		bonuses_label.text += "\nCoins: " + str(points);
		AudioManager.play_audio(AudioManager.SLIME_IMPACT_SLAP);
		await get_tree().create_timer(0.25).timeout;
		
		points += (player.health * PER_HP_BONUS) + FINISHED_BONUS;
	
	await get_tree().create_timer(0.25).timeout;
	points_label.visible = true;
	AudioManager.play_audio(AudioManager.SCORING_NOTE_BLUE);
	if points > 0:
		var tween = get_tree().create_tween();
		tween.tween_method(update_score, 0, points, 1).set_ease(Tween.EASE_IN_OUT);
		await tween.finished;
	
	await get_tree().create_timer(0.25).timeout;
	restart_button.visible = true;
	AudioManager.play_audio(AudioManager.SCORING_NOTE_RED);

func update_score(value: int) -> void:
	points_label.text = str(value) + " Points";

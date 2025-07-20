extends Control

@onready var invert_camera_checkbox: CheckBox = %InvertCameraCheckbox
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var back_button: Button = %BackButton

var ui: UI;

func _ready() -> void:
	ui = get_parent();
	invert_camera_checkbox.pressed.connect(on_invert_camera_checkbox_changed);
	sensitivity_slider.value_changed.connect(on_sensitivity_slider_changed);
	music_slider.value_changed.connect(on_music_slider_changed);
	sfx_slider.value_changed.connect(on_sfx_slider_changed);
	back_button.pressed.connect(on_back_button_pressed);
	
	invert_camera_checkbox.button_pressed = Globals.is_look_inverted;
	sensitivity_slider.value = Globals.camera_sensitivity_setting;
	
	music_slider.value = AudioManager.music_volume;
	music_slider.value_changed.emit(music_slider.value);
	
	sfx_slider.value = AudioManager.sfx_volume;
	sfx_slider.value_changed.emit(sfx_slider.value);

func on_invert_camera_checkbox_changed() -> void:
	Globals.is_look_inverted = !Globals.is_look_inverted;
	
func on_sensitivity_slider_changed(value: float) -> void:
	Globals.camera_sensitivity_setting = value;

func on_music_slider_changed(value: float) -> void:
	AudioManager.music_volume = value;
	AudioManager.set_volume("Music", value);

func on_sfx_slider_changed(value: float) -> void:
	AudioManager.sfx_volume = value;
	AudioManager.set_volume("SFX", value);

func on_back_button_pressed() -> void:
	ui.unpause();

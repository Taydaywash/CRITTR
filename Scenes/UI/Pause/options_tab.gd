extends pause_tab

@onready var window = get_window()
const TITLE_SCREEN = "res://Scenes/Title/TitleScreen.tscn"

const SLOW_TEXT_SPEED : float = 0.4
const FAST_TEXT_SPEED : float = 0.2
const INSTANT_TEXT_SPEED : float = 0
const TEXT_SPEEDS = [SLOW_TEXT_SPEED,FAST_TEXT_SPEED,INSTANT_TEXT_SPEED]
const TEXT_SPEEDS_NAMES = ["SLOW","FAST","INSTANT"]
var text_speeds_index = 0

@export var screen_size_dropdown : OptionButton
@export var resolution_dropdown : OptionButton
@export var master_volume_slider : HSlider
@export var music_volume_slider : HSlider
@export var sfx_volume_slider : HSlider
@export var text_scroll_speed_value : Label
@export var disable_partilces_button : Button
@onready var audio_controller : AudioListener2D = get_parent().audio_controller

var current_options : Dictionary = {
	"screen_size": DisplayServer.WINDOW_MODE_WINDOWED,
	"on_top" : false,
	"master_volume": 50,
	"music_volume": 50,
	"sfx_volume": 50,
	"screen_resolution" : Vector2(1152, 648),
	"text_speed" : 0.4,
	"disabled_particles" : false,
}

var temp_options : Dictionary

func _ready() -> void:
	current_options = SaveLoadManager.load_options()
	temp_options = current_options.duplicate()
	update_screen_settings()
	apply_settings()

func options_opened() -> void:
	temp_options = current_options.duplicate()
	resolution_dropdown.select(get_resolution_dropdown_index())
	screen_size_dropdown.select(get_screen_size_dropdown_index())
	master_volume_slider.value = current_options.master_volume
	music_volume_slider.value = current_options.music_volume
	sfx_volume_slider.value = current_options.sfx_volume
	update_text_scroll_speed_text()
	update_disable_particles_button()

func options_closed() -> void:
	temp_options = current_options.duplicate()

func update_screen_settings() -> void:
	DisplayServer.window_set_mode(current_options.screen_size)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP,current_options.on_top)
	if current_options.screen_size == DisplayServer.WINDOW_MODE_WINDOWED:
		window.size = current_options.screen_resolution

func get_resolution_dropdown_index() -> int:
	var index = 0
	match current_options.screen_resolution:
		Vector2(3840, 2160): index = 0
		Vector2(1920, 1080): index = 1
		Vector2(1440, 900): index = 2
		Vector2(1366, 768): index = 3
		Vector2(1280, 720): index = 4
		Vector2(1152, 648): index = 5
	return index

func _on_resolution_item_selected(index: int) -> void:
	match index:
		0: temp_options.screen_resolution = Vector2(3840, 2160) #print("3840 x 2160")
		1: temp_options.screen_resolution = Vector2(1920, 1080) #print("1920 x 1080")
		2: temp_options.screen_resolution = Vector2(1440, 900) #print("1440 x 900")
		3: temp_options.screen_resolution = Vector2(1366, 768) #print("1366 x 768")
		4: temp_options.screen_resolution = Vector2(1280, 720) #print("1280 x 720")
		5: temp_options.screen_resolution = Vector2(1152, 648) #print("1152 x 648")

func get_screen_size_dropdown_index() -> int:
	var index = 0
	match current_options.screen_size:
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: index =  0
		DisplayServer.WINDOW_MODE_WINDOWED: index = 1
		DisplayServer.WINDOW_MODE_FULLSCREEN: index = 2
	return index

func _on_screen_size_item_selected(index: int) -> void:
	match index:
		0: #Fullscreen
			temp_options.screen_size = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
			temp_options.on_top = true
		1: #Windowed
			temp_options.screen_size = DisplayServer.WINDOW_MODE_WINDOWED
			temp_options.borderless = false
		2: #Borderless fullscreen
			temp_options.screen_size = DisplayServer.WINDOW_MODE_FULLSCREEN
			temp_options.borderless = false

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if pause_screen.current_tab == pause_screen.options_tab:
			pause_screen.options_button.grab_focus()
	if event.is_action_released("ui_accept"):
		if pause_screen.current_tab == pause_screen.options_tab and pause_screen.options_button.has_focus():
			default_focus.grab_focus()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCREEN)

func _on_decrease_pressed() -> void:
	if text_speeds_index > 0:
		text_speeds_index -= 1
	temp_options.text_speed = TEXT_SPEEDS[text_speeds_index]
	update_text_scroll_speed_text()
func _on_increase_pressed() -> void:
	if text_speeds_index < 2:
		text_speeds_index += 1
	temp_options.text_speed = TEXT_SPEEDS[text_speeds_index]
	update_text_scroll_speed_text()

func get_text_speeds_index() -> int:
	match temp_options.text_speed:
		SLOW_TEXT_SPEED: text_speeds_index = 0
		FAST_TEXT_SPEED: text_speeds_index = 1
		INSTANT_TEXT_SPEED: text_speeds_index = 2
	return text_speeds_index

func update_text_scroll_speed_text() -> void:
	text_scroll_speed_value.text = TEXT_SPEEDS_NAMES[get_text_speeds_index()]

func _on_master_volume_value_changed(value: float) -> void:
	temp_options.master_volume = value
func _on_music_volume_value_changed(value: float) -> void:
	temp_options.music_volume = value
func _on_sfx_volume_value_changed(value: float) -> void:
	temp_options.sfx_volume = value

func _on_disable_particles_pressed() -> void:
	temp_options.disabled_particles = !temp_options.disabled_particles
	update_disable_particles_button()

func update_disable_particles_button() -> void:
	disable_partilces_button.text = ""
	if temp_options.disabled_particles:
		disable_partilces_button.text = "x"

func _on_save_changes_pressed() -> void:
	current_options = temp_options.duplicate()
	apply_settings()
	SaveLoadManager.save_options(current_options)

func apply_settings():
	update_screen_settings()
	audio_controller.change_master_volume_to(temp_options.master_volume/100.0)
	audio_controller.change_music_volume_to(temp_options.music_volume/100.0)
	audio_controller.change_sfx_volume_to(temp_options.sfx_volume/100.0)

extends pause_tab

@onready var window = get_window()
const TITLE_SCREEN = "res://Scenes/Title/TitleScreen.tscn"

const SLOW_TEXT_SPEED : float = 0.8
const FAST_TEXT_SPEED : float = 0.4
const INSTANT_TEXT_SPEED : float = 0
const TEXT_SPEEDS = [SLOW_TEXT_SPEED,FAST_TEXT_SPEED,INSTANT_TEXT_SPEED]
var text_speeds_index = 0

@export var screen_size_dropdown : OptionButton
@export var resolution_dropdown : OptionButton
@export var text_scroll_speed_value : Label

var options : Dictionary = {
	"screen_size": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"borderless" : false,
	"screen_resolution" : Vector2(1152, 648),
	"text_speed" : 0,
}

func _ready() -> void:
	update_screen_settings()

func update_screen_settings():
	DisplayServer.window_set_mode(options.screen_size)
	if (options.screen_size != DisplayServer.WINDOW_MODE_FULLSCREEN):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		window.size = options.screen_resolution
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, options.borderless)
	screen_size_dropdown.selected = get_screen_size_dropdown_index()
	resolution_dropdown.selected = get_resolution_dropdown_index()
	if (options.screen_size == DisplayServer.WINDOW_MODE_FULLSCREEN and 
	DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)):
		print("f")
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func get_screen_size_dropdown_index() -> int:
	var index = 0
	match options.screen_size:
		DisplayServer.WINDOW_MODE_FULLSCREEN: index =  0
		DisplayServer.WINDOW_MODE_WINDOWED: index = 2
	index += int(options.borderless)
	return index
func get_resolution_dropdown_index():
	var index = 0
	match options.screen_resolution:
		Vector2(3840, 2160): index = 0
		Vector2(1920, 1080): index = 1
		Vector2(1440, 900): index = 2
		Vector2(1366, 768): index = 3
		Vector2(1280, 720): index = 4
		Vector2(1152, 648): index = 5
	return index

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if pause_screen.current_tab == pause_screen.options_tab:
			pause_screen.options_button.grab_focus()
	if event.is_action_released("ui_accept"):
		if pause_screen.current_tab == pause_screen.options_tab and pause_screen.options_button.has_focus():
			default_focus.grab_focus()

func _on_screen_size_item_selected(index: int) -> void:
	match index:
		0: #Fullscreen
			options.screen_size = DisplayServer.WINDOW_MODE_FULLSCREEN
			options.borderless = false
		1: #Borderless fullscreen
			options.screen_size = DisplayServer.WINDOW_MODE_FULLSCREEN
			options.borderless = true
		2: #Windowed
			options.screen_size = DisplayServer.WINDOW_MODE_WINDOWED
			options.borderless = false
		3: #Borderless Windowed
			options.screen_size = DisplayServer.WINDOW_MODE_WINDOWED
			options.borderless = true
	update_screen_settings()

func _on_resolution_item_selected(index: int) -> void:
	match index:
		0: options.screen_resolution = Vector2(3840, 2160) #print("3840 x 2160")
		1: options.screen_resolution = Vector2(1920, 1080) #print("1920 x 1080")
		2: options.screen_resolution = Vector2(1440, 900) #print("1440 x 900")
		3: options.screen_resolution = Vector2(1366, 768) #print("1366 x 768")
		4: options.screen_resolution = Vector2(1280, 720) #print("1280 x 720")
		5: options.screen_resolution = Vector2(1152, 648) #print("1152 x 648")
	update_screen_settings()
	
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCREEN)

func _on_decrease_pressed() -> void:
	if text_speeds_index > 0:
		text_speeds_index -= 1
	update_text_scroll_speed()
func _on_increase_pressed() -> void:
	if text_speeds_index < 2:
		text_speeds_index += 1
	update_text_scroll_speed()
func update_text_scroll_speed():
	options.text_speed = TEXT_SPEEDS[text_speeds_index]
	if TEXT_SPEEDS[text_speeds_index] == SLOW_TEXT_SPEED:
		text_scroll_speed_value.text = "Slow"
	elif TEXT_SPEEDS[text_speeds_index] == FAST_TEXT_SPEED:
		text_scroll_speed_value.text = "Fast"
	else:
		text_scroll_speed_value.text = "Instant"

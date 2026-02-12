extends pause_tab

@onready var window = get_window()

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if pause_screen.current_tab == pause_screen.options_tab:
			pause_screen.options_button.grab_focus()
	if event.is_action_released("ui_accept"):
		if pause_screen.current_tab == pause_screen.options_tab and pause_screen.options_button.has_focus():
			default_focus.grab_focus()

func _on_screen_size_item_selected(index: int) -> void:
	match index:
		0: 
			#window.mode = Window.MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: 
			#window.mode = Window.FLAG_BORDERLESS
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

func _on_resolution_item_selected(index: int) -> void:
	match index:
		0: window.size = Vector2(3840, 2160) #print("3840 x 2160")
		1: window.size = Vector2(1920, 1080) #print("1920 x 1080")
		2: window.size = Vector2(1440, 900) #print("1440 x 900")
		3: window.size = Vector2(1366, 768) #print("1366 x 768")
		4: window.size = Vector2(1280, 720) #print("1280 x 720")
		5: window.size = Vector2(1152, 684) #print("1152 x 684")
	window.content_scale_size = window.size

func _on_setting_button_pressed() -> void:
	pass # Replace with function body.
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Title/TitleScreen.tscn")

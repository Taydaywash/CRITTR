extends pause_tab

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if pause_screen.current_tab == pause_screen.options_tab:
			pause_screen.options_button.grab_focus()
	if event.is_action_released("ui_accept"):
		if pause_screen.current_tab == pause_screen.options_tab and pause_screen.options_button.has_focus():
			default_focus.grab_focus()

func _on_screen_size_item_selected(index: int) -> void:
	match index:
		0: print("fullscreen")
		1: print("windowned fullscreen")
		2: print("windowed")

func _on_resolution_item_selected(index: int) -> void:
	match index:
		0: print("3840 x 2160")
		1: print("1920 x 1080")
		2: print("1440 x 900")
		3: print("1366 x 768")
		4: print("1280 x 720")
		5: print("1152 x 684")

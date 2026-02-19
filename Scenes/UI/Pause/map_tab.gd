extends pause_tab

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		if pause_screen.current_tab == pause_screen.map_tab:
			default_focus.grab_focus()
	if event.is_action_released("ui_cancel"):
		if pause_screen.current_tab == pause_screen.map_tab:
			pause_screen.map_button.grab_focus()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if pause_screen.current_tab == pause_screen.map_tab:
			default_focus.grab_focus()

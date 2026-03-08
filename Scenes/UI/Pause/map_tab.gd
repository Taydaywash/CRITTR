extends pause_tab

func handle_input(event: InputEvent) -> void:
	if pause_screen.map.teleport_confirm.visible:
		pause_screen.map.handle_input(event)
		return
	if event.is_action_released("ui_accept"):
		if default_focus.has_focus():
			pause_screen.map.handle_input(event)
			return
		default_focus.grab_focus()
		return
	if event.is_action_released("ui_cancel"):
		pause_screen.map_button.grab_focus()
		return

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if pause_screen.current_tab == pause_screen.map_tab:
			default_focus.grab_focus()

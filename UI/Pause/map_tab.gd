extends pause_tab

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		if pause_screen.current_tab == pause_screen.map_tab:
			default_focus.grab_focus()
	if event.is_action_released("ui_cancel"):
		if pause_screen.current_tab == pause_screen.map_tab:
			pause_screen.map_button.grab_focus()
func _process(_delta: float) -> void:
	if default_focus.has_focus():
		if Input.is_action_pressed("move_up"):
			pause_screen.map.camera.position.y -= pause_screen.map.camera_move_speed
		if Input.is_action_pressed("move_down"):
			pause_screen.map.camera.position.y += pause_screen.map.camera_move_speed
		if Input.is_action_pressed("move_left"):
			pause_screen.map.camera.position.x -= pause_screen.map.camera_move_speed
		if Input.is_action_pressed("move_right"):
			pause_screen.map.camera.position.x += pause_screen.map.camera_move_speed

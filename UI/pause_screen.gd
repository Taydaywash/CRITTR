extends CanvasLayer

var paused = true

func _ready() -> void:
	toggle_pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	paused = !paused
	visible = paused
	get_tree().paused = paused

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_setting_button_pressed() -> void:
	pass # Replace with function body.

func _on_main_menu_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file("res://Title/TitleScreen.tscn")

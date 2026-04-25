extends ChoicerHandler
const TITLE_SCREEN = "res://Scenes/Title/TitleScreen.tscn"
func on_confirm_pressed() -> void:
	var data : Dictionary = {
		"last_respawn_point": %Player.respawn_controller_reference.respawn_position
	}
	EventController.emit_signal("save_and_quit",data)
	get_tree().change_scene_to_file(TITLE_SCREEN)

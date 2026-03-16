extends ChoicerHandler

func on_confirm_pressed() -> void:
	super()
func on_cancel_pressed() -> void:
	get_tree().paused = false
	super()

extends ChoicerHandler
func on_confirm_pressed() -> void:
	get_parent()._on_confirm_teleport()
func on_cancel_pressed() -> void:
	super()
	get_parent()._on_cancel_teleport()

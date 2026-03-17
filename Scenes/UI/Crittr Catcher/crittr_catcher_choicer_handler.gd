extends ChoicerHandler

@onready var crittr_catcher: CanvasLayer = %CrittrCatcher

func on_confirm_pressed() -> void:
	ui.reset_choicer_text()
	crittr_catcher.exit_crittr_catcher()
func on_cancel_pressed() -> void:
	super()

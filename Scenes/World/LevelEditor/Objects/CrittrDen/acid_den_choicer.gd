extends ChoicerHandler

@onready var crittr_catcher = %CrittrCatcher

func on_confirm_pressed() -> void:
	ui.reset_choicer_text()
	crittr_catcher.initial_level = 1
	crittr_catcher.enter_crittr_catcher(crittr_catcher.ACID_FROG_LEVEL_POOL,"grapple")

func on_cancel_pressed() -> void:
	get_tree().paused = false
	super()

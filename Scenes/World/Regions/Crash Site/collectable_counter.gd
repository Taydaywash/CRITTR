extends interactable

@onready var ui = %UI

@export var dialog_string : String

func _input(_event: InputEvent) -> void:
	if overlapping and can_interact():
		if Input.is_action_just_pressed("interact"):
			get_tree().paused = true
			ui.text_popup("You have collected %s Strange Scraps" % (GameController.game_state.total_collectables))

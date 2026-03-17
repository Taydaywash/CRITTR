extends interactable

@onready var crittr_catcher = %CrittrCatcher
@onready var ui = %UI

@export var choicer_handler : ChoicerHandler

@export var dialog_string : String

func _input(_event: InputEvent) -> void:
	if overlapping and can_interact():
		if Input.is_action_just_pressed("interact"):
			get_tree().paused = true
			ui.start_typing_choicer_text(Dialog.from_string[dialog_string],choicer_handler)

extends interactable

const ABILITY_CHANGE_MENU = preload("uid://c2l75c4nehnvg")
var ability_change_menu_reference : CanvasLayer
#used_ability_station
@onready var pause_screen : CanvasLayer = get_node("/root/World/PauseScreen")

func _input(_event: InputEvent) -> void:
	if overlapping and can_interact():
		if Input.is_action_just_pressed("interact"):
			pause_screen.toggle_pause(true)

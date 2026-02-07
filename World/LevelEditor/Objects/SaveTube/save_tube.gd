extends interactable

const ABILITY_CHANGE_MENU = preload("uid://c2l75c4nehnvg")
var ability_change_menu_reference : CanvasLayer

func _input(_event: InputEvent) -> void:
	if overlapping and can_interact():
		if Input.is_action_just_pressed("interact") and not ability_change_menu_reference:
			ability_change_menu_reference = ABILITY_CHANGE_MENU.instantiate()
			add_child(ability_change_menu_reference)
			ability_change_menu_reference.visible = true
	if ability_change_menu_reference:
		if ability_change_menu_reference.visible:
			player.state_machine.force_change_state(player.state_machine.no_control_state)
		else:
			player.state_machine.force_change_state(player.state_machine.idle_state)
			ability_change_menu_reference.queue_free()

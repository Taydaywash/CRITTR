extends pause_tab

@export var up_ability : Button
@export var down_ability : Button
@export var left_ability : Button
@export var right_ability : Button
@onready var abilities: AbilityController = get_node("/root/World/Player/StateMachine/Abilities")

var held_ability : State

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if up_ability.has_focus() or down_ability.has_focus() or left_ability.has_focus() or right_ability.has_focus():
			default_focus.grab_focus()
		elif pause_screen.current_tab == pause_screen.dna_tab:
			pause_screen.dna_button.grab_focus()
func update_ability_icons() -> void:
	up_ability.icon = abilities.abilities_in_use.ability_up.texture
	down_ability.icon = abilities.abilities_in_use.ability_down.texture
	left_ability.icon = abilities.abilities_in_use.ability_left.texture
	right_ability.icon = abilities.abilities_in_use.ability_right.texture
func _on_dna_button_pressed() -> void:
	default_focus.grab_focus()
func _on_dash_focus_entered() -> void:
	if not pause_screen.used_save_point:
		pause_screen.dna_button.grab_focus()
func _on_dash_pressed() -> void:
	ability_pressed(index_to_ability(0))
func _on_grapple_pressed() -> void:
	ability_pressed(index_to_ability(1))
func _on_climb_pressed() -> void:
	ability_pressed(index_to_ability(2))
func _on_inflate_pressed() -> void:
	ability_pressed(index_to_ability(3))
func _on_drill_pressed() -> void:
	ability_pressed(index_to_ability(4))
func _on_bounce_pressed() -> void:
	ability_pressed(index_to_ability(5))
func index_to_ability(index):
	if index == 0:
		return abilities.dashing_state
	if index == 1:
		return abilities.grappling_state
	if index == 2:
		return abilities.climbing_state
	if index == 3:
		return abilities.inflated_state
	if index == 4:
		return abilities.drill_state
	if index == 5:
		return abilities.bounce_attack_state
func ability_pressed(ability : State):
	held_ability = ability
	up_ability.grab_focus()

func _on_up_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("up",held_ability)
	default_focus.grab_focus()
	update_ability_icons()
	held_ability = null
func _on_down_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("down",held_ability)
	default_focus.grab_focus()
	update_ability_icons()
	held_ability = null
func _on_left_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("left",held_ability)
	default_focus.grab_focus()
	update_ability_icons()
	held_ability = null
func _on_right_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("right",held_ability)
	default_focus.grab_focus()
	update_ability_icons()
	held_ability = null

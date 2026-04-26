extends pause_tab

const directions = ["up","down","left","right"]

@export var up_ability : Button
@export var down_ability : Button
@export var left_ability : Button
@export var right_ability : Button
@onready var abilities: AbilityController = get_node("/root/World/Player/StateMachine/Abilities")

@export var dash_button : Button
@export var grapple_button : Button
@export var climb_button : Button
@export var inflate_button : Button
@export var drill_button : Button
@export var bounce_button : Button

var held_ability : State

var ability_data = {
	"ability" : null,
	"direction" : ""
}

var ability_queue = []

const UI_HOVER = preload("uid://bvfiha76ltfmi")
const UI_CANCEL = preload("uid://ejjyhdoxq4xd")
const UI_CONFIRM = preload("uid://c3jo2nkgwvncg")
@onready var audio_controller : AudioController = get_parent().audio_controller

func _ready() -> void:
	ability_queue = indices_to_states(GameController.get_current_abilities())
	update_abilities()

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if up_ability.has_focus() or down_ability.has_focus() or left_ability.has_focus() or right_ability.has_focus():
			default_focus.grab_focus()
		elif pause_screen.current_tab == pause_screen.dna_tab:
			pause_screen.dna_button.grab_focus()
func dna_tab_opened() -> void:
	if pause_screen.paused:
		audio_controller.play_sound(UI_CONFIRM)
	update_ability_unlocks(GameController.get_abilities_unlocked())
	update_ability_icons()
	
func update_ability_unlocks(ability_unlocks) -> void:
	dash_button.disabled = !ability_unlocks.dash
	grapple_button.disabled = !ability_unlocks.grapple
	climb_button.disabled = !ability_unlocks.climb
	inflate_button.disabled = !ability_unlocks.inflate
	drill_button.disabled = !ability_unlocks.drill
	bounce_button.disabled = !ability_unlocks.bounce
func update_ability_icons() -> void:
	up_ability.icon = abilities.abilities_in_use.ability_up.texture
	if abilities.abilities_in_use.ability_up.state == null:
		up_ability.icon = null
	down_ability.icon = abilities.abilities_in_use.ability_down.texture
	left_ability.icon = abilities.abilities_in_use.ability_left.texture
	right_ability.icon = abilities.abilities_in_use.ability_right.texture
func _on_dna_button_pressed() -> void:
	audio_controller.play_sound(UI_CONFIRM)
	default_focus.grab_focus()
func _on_dna_buttons_focus_entered() -> void:
	audio_controller.play_sound(UI_HOVER)
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
	if abilities.abilities_in_use["ability_up"].state != held_ability:
		#abilities.set_ability("up",held_ability)
		add_ability("up")
func _on_down_pressed() -> void:
	if not held_ability:
		return
	if abilities.abilities_in_use["ability_down"].state != held_ability:
		#abilities.set_ability("down",held_ability)
		add_ability("down")
func _on_left_pressed() -> void:
	if not held_ability:
		return
	if abilities.abilities_in_use["ability_left"].state != held_ability:
		#abilities.set_ability("left",held_ability)
		add_ability("left")
func _on_right_pressed() -> void:
	if not held_ability:
		return
	if abilities.abilities_in_use["ability_right"].state != held_ability:
		#abilities.set_ability("right",held_ability)
		add_ability("right")
	
func add_ability(direction : String) -> void:
	var usages = 0
	
	for ability_index in range(ability_queue.size()):
		if ability_queue[ability_index].ability == held_ability:
			usages += 1
		if usages >= GameController.ability_usages:
			ability_queue.remove_at(ability_index)
			break
	for ability_index in range(ability_queue.size()):
		if ability_queue[ability_index].direction == direction:
			ability_queue.remove_at(ability_index)
			break
	ability_data.ability = held_ability
	ability_data.direction = direction
	ability_queue.insert(0,ability_data.duplicate())
	
	update_abilities()
	default_focus.grab_focus()
	held_ability = null

func update_abilities():
	for direction in directions:
		abilities.set_ability(direction,null)
	for direction in directions:
		for element in ability_queue:
			if element.direction == direction:
				abilities.set_ability(direction,element.ability)
	EventController.emit_signal("update_current_abilities",states_to_indices())
	update_ability_icons()
func states_to_indices():
	var indexed_ability_queue := []
	for element in ability_queue:
		ability_data.direction = element.direction
		match element.ability:
			abilities.dashing_state:
				ability_data.ability = 0
			abilities.grappling_state:
				ability_data.ability = 1
			abilities.climbing_state:
				ability_data.ability = 2
			abilities.inflated_state:
				ability_data.ability = 3
			abilities.drill_state:
				ability_data.ability = 4
			abilities.bounce_attack_state:
				ability_data.ability = 5
		indexed_ability_queue.append(ability_data.duplicate())
	return indexed_ability_queue.duplicate(true)

func indices_to_states(indexed_ability_queue):
	var unindexed_ability_queue := []
	for element in indexed_ability_queue:
		ability_data.direction = element.direction
		match element.ability:
			0:
				ability_data.ability = abilities.dashing_state
			1:
				ability_data.ability = abilities.grappling_state
			2:
				ability_data.ability = abilities.climbing_state
			3:
				ability_data.ability = abilities.inflated_state
			4:
				ability_data.ability = abilities.drill_state
			5:
				ability_data.ability = abilities.bounce_attack_state
		unindexed_ability_queue.append(ability_data.duplicate())
	return unindexed_ability_queue.duplicate(true)

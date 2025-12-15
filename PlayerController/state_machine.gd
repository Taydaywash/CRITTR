extends Node

@onready var abilities: Node = $Abilities

@export
var starting_state : State
@export
var grounded_states : Array[State]
var current_state : State

#initialize state machine by taking player 
#reference and propagating it to each state
func initialize(player : CharacterBody2D) -> void:
	for child in get_children():
		child.parent = player
	for child in get_child(get_children().size() - 1).get_children():
		child.parent = player
	#Initialize with starting_state
	change_state(starting_state, null)

#Change current state afer deactivating currently active state
func change_state(new_state : State, direction) -> void:
	var last_state = current_state
	if current_state:
		current_state.deactivate()
	current_state = new_state
	if grounded_states.has(current_state) or (last_state == $Falling and new_state == $Jumping):
		abilities.refill_abilities()
	if direction:
		current_state.set_direction(direction)
	current_state.activate(last_state)

#Propagate down from state machine to active state
func process_input(event) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		if new_state == $Abilities:
			var ability = abilities.get_ability(event)
			if ability.available:
				abilities.use_ability(event)
				change_state(ability.state, ability.direction)
		else:
			change_state(new_state, null)

func process_physics(delta) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state, null)
func process_frame(delta) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state, null)

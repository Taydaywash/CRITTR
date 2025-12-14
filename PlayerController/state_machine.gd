extends Node

@export
var starting_state : State

var current_state : State

#initialize state machine by taking player 
#reference and propagating it to each state
func initialize(player : CharacterBody2D) -> void:
	for child in get_children():
		child.parent = player
	#Initialize with starting_state
	change_state(starting_state)

#Change current state afer deactivating currently active state
func change_state(new_state : State) -> void:
	var last_state = current_state
	if current_state:
		current_state.deactivate()
	current_state = new_state
	current_state.activate(last_state)

#Propagate down from state machine to active state
func process_input(event) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)
func process_physics(delta) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)
func process_frame(delta) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

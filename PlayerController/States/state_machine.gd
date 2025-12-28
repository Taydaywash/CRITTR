extends Node

@onready var abilities: Node = $Abilities

@export var no_control_state : State
@export var death_state : State
@export var idle_state : State
@export var colliders_list : Array[CollisionShape2D]
@export var starting_state : State
@export var grounded_states : Array[State]
@export var abilities_state : State
var current_state : State
var player_reference: CharacterBody2D 
var player_sprite: AnimatedSprite2D

#initialize state machine by taking player 
#reference and propagating it to each state
func check_children(parent : Node) -> void: 
	for child in parent.get_children():
		if child is Timer:
			return
		child.parent = player_reference
		child.sprite = player_sprite
		child.colliders = colliders_list
		if child.get_child_count() > 0:
			check_children(child)

func initialize(player : CharacterBody2D, sprite : AnimatedSprite2D) -> void:
	player_reference = player
	player_sprite = sprite
	
	check_children(self)
	
	#Old code keep in case. DON'T DELETE!!
	#for child in get_children():
		#child.parent = player
		#child.sprite = sprite
		#child.colliders = colliders_list
	#for child in get_child(get_children().size() - 1).get_children():
		#child.parent = player
		#child.sprite = sprite
		#child.colliders = colliders_list
	
	#Initialize with starting_state
	change_state(starting_state)

#Change current state afer deactivating currently active state
func change_state(new_state : State, direction = null) -> void:
	var last_state = current_state
	if current_state:
		current_state.deactivate(new_state)
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
			var ability = abilities.get_ability()
			if ability:
				if abilities.abilities_in_use[ability].available:
					abilities.use_ability(ability)
					change_state(abilities.abilities_in_use[ability].state, abilities.abilities_in_use[ability].direction)
		else:
			change_state(new_state)

func process_physics(delta) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)
func process_frame(delta) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
func force_change_state(state : State): #Must be called with the call_deferred method to work properly
	change_state(state)

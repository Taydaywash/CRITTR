@icon("res://Assets/Editor Icons/Gear Icon.png")
class_name StateMachine
extends Node

@onready var abilities: Node = $Abilities

@export var no_control_state : State
@export var no_control_no_gravity_state : State
@export var death_state : State
@export var teleporting_enter_state : State
@export var teleporting_exit_state : State

@export var spawning_state : State
@export var jumping_state : State
@export var star_bounce_state : State
@export var crouching_state : State
@export var idle_crouching_state : State
@export var idle_state : State
@export var looking_up_state : State
@export var walking_state : State
@export var diving_state : State
@export var diving_falling_state : State
@export var bonked_state : State
@export var wall_cling_state : State
@export var wall_jumping_state : State
@export var falling_state : State
@export var ascending_state : State
@export var ability_state : State
@export var dashing_state : State
@export var grappling_pull_state : State
@export var inflated_state : State
@export var climbing_slide_state : State
@export var digging_state : State
@export var bounce_attack_state : State

@export_category("")
@export var colliders_list : Array[CollisionShape2D]
@export var hurtboxes_list : Array[Area2D]
@export var starting_state : State
@export var grounded_states : Array[State]
@export var abilities_state : State
@export_category("Timers")
@export var jump_input_buffer : Timer
var current_state : State
var player_reference: CharacterBody2D 
var audio_controller_reference : AudioController
var particle_controller_reference : ParticleController
var player_sprite: AnimatedSprite2D
var last_state

#initialize state machine by taking player 
#reference and propagating it to each state
func check_children(parent : Node) -> void: 
	for child in parent.get_children():
		if child is not State:
			return
		child.player = player_reference
		child.audio_controller = audio_controller_reference
		child.particle_controller = particle_controller_reference
		child.sprite = player_sprite
		child.colliders = colliders_list
		child.hurtboxes = hurtboxes_list
		
		child.no_control_state = no_control_state
		child.no_control_no_gravity_state = no_control_no_gravity_state
		child.death_state = death_state
		child.spawning_state = spawning_state
		child.jumping_state = jumping_state
		child.star_bounce_state = star_bounce_state
		child.crouching_state = crouching_state
		child.idle_crouching_state = idle_crouching_state
		child.idle_state = idle_state
		child.looking_up_state = looking_up_state
		child.walking_state = walking_state
		child.diving_state = diving_state
		child.diving_falling_state = diving_falling_state
		child.bonked_state = bonked_state
		child.wall_cling_state = wall_cling_state
		child.wall_jumping_state = wall_jumping_state
		child.falling_state = falling_state
		child.ascending_state = ascending_state
		child.ability_state = ability_state
		child.dashing_state = dashing_state
		child.grappling_pull_state = grappling_pull_state
		child.climbing_slide_state = climbing_slide_state
		child.inflated_state = inflated_state
		child.digging_state = digging_state
		child.bounce_attack_state = bounce_attack_state
		
		if child.get_child_count() > 0:
			check_children(child)

func initialize(player : Player, sprite : AnimatedSprite2D) -> void:
	player_reference = player
	player_sprite = sprite
	audio_controller_reference = player.audio_controller_reference
	particle_controller_reference = player.particle_controller_reference
	check_children(self)
	change_state(starting_state)

#Change current state afer deactivating currently active state
func change_state(new_state : State, direction = null, discrete : bool = false) -> void:
	last_state = current_state
	if current_state:
		if not discrete:
			if new_state in abilities_state.get_children():
				current_state.deactivate(abilities_state)
			else:
				current_state.deactivate(new_state)
	current_state = new_state
	if grounded_states.has(current_state) or ((last_state == falling_state or last_state == diving_falling_state) and current_state == jumping_state):
		abilities.refill_abilities()
	if direction:
		current_state.set_direction(direction)
		for child in current_state.get_children():
			if child is State: 
				child.set_direction(direction)
	if not discrete:
		current_state.activate(last_state)
	

#Propagate down from state machine to active state
func process_input(event) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		if new_state == $Abilities:
			var ability = abilities.get_ability()
			if ability:
				if not abilities.abilities_in_use[ability].state:
					return
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
func force_change_state(state : State, discrete : bool = true): 
	#Must be call deferred
	change_state(state, null, discrete)

extends Node

@export var up_velocity_room_transition : float
@export var down_velocity_room_transition : float
@export var horizontal_velocity_room_transition : float
@export var first_room : Room
@export var screen_fade_speed : float

@onready var ui: CanvasLayer = $"../UI"
@onready var player: CharacterBody2D = $"../PlayerController"

var previous_room : Room
var current_room : Room = null
var next_room : Room

var fade_in : bool
var fade_out : bool
var respawn_position : Vector2
func _ready() -> void:
	current_room = first_room
	first_room.enter_room()

func entered_room(room : Room):
	next_room = room

func respawn(respawn_pos : Vector2):
	fade_in = true
	fade_out = false
	respawn_position = respawn_pos

func exited_room(room : Room):
	if room == current_room:
		previous_room = current_room
		current_room = null
		fade_in = true
		fade_out = false
	else:
		next_room = null

func _process(delta: float) -> void:
	if fade_in:
		ui.increment_fade_in(delta, screen_fade_speed)
		if !ui.is_fading_in():
			fade_in = false
			fade_out = true
	if !current_room and next_room:
		set_enter_velocity()
		if !fade_in and fade_out:
			transition_room()
	if player.state_machine.current_state == player.state_machine.no_control_state:
		if !fade_in and fade_out:
			player.get_state_machine().change_state(player.get_state_machine().starting_state,null)
			player.set_deferred("position",respawn_position)
	if fade_out:
		ui.increment_fade_out(delta, screen_fade_speed)
		if !ui.is_fading_out():
			fade_out = false

func transition_room():
	previous_room.exit_room()
	current_room = next_room
	next_room.enter_room()
func set_enter_velocity():
	if player.velocity.y < 0:
		player.velocity.y = -up_velocity_room_transition
	elif player.velocity.y > 0:
		player.velocity.y = down_velocity_room_transition
	elif player.velocity.x > 0:
		player.velocity.x = horizontal_velocity_room_transition
	elif player.velocity.x < 0:
		player.velocity.x = -horizontal_velocity_room_transition

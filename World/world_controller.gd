extends Node

@export var up_velocity_room_transition : float
@export var down_velocity_room_transition : float
@export var horizontal_velocity_room_transition : float
@export var first_room : Room
@export var screen_fade_speed : float
@export var player_control_regain_delay : float

@onready var ui: CanvasLayer = $"../UI"
@onready var player: CharacterBody2D = $"../Player"

var previous_room : Room
var current_room : Room = null
var next_room : Room

var fade_in : bool = false
var screen_is_black : bool = false
var fade_out : bool = false
var respawn_position : Vector2
var player_control_regain : Timer

var respawning : bool = false
var room_transitioning : bool = false

func _ready() -> void:
	player_control_regain = Timer.new()
	player_control_regain.wait_time = player_control_regain_delay
	player_control_regain.one_shot = true
	self.add_child(player_control_regain)
	current_room = first_room
	first_room.enter_room()

func entered_room(room : Room):
	next_room = room
	#exited_room(current_room)

func respawn(respawn_pos : Vector2):
	fade_in = true
	fade_out = false
	respawn_position = respawn_pos
	respawning = true

func exited_room(room : Room):
	if room == current_room:
		previous_room = current_room
		current_room = null
		fade_in = true
		fade_out = false
		room_transitioning = true
	else:
		next_room = null

func _process(delta: float) -> void:
	if fade_in:
		ui.increment_fade_in(delta, screen_fade_speed)
		if not ui.is_fading_in():
			fade_in = false
			screen_is_black = true
	if room_transitioning:
		set_enter_velocity()
	if screen_is_black:
		if room_transitioning:
			transition_room()
			room_transitioning = false
		elif respawning:
			player.get_state_machine().change_state(player.get_state_machine().starting_state,null)
			player.get_camera().set_deferred("position_smoothing_enabled", false)
			player.set_deferred("position",respawn_position)
		fade_out = true
		screen_is_black = false
	if fade_out:
		ui.increment_fade_out(delta, screen_fade_speed)
		if !ui.is_fading_out():
			player.get_camera().set_deferred("position_smoothing_enabled", true)
			fade_out = false

func transition_room():
	if previous_room == null:
		previous_room = first_room
	if next_room == null:
		next_room = first_room
	previous_room.exit_room()
	current_room = next_room
	next_room.enter_room()
	next_room = null
func set_enter_velocity():
	if player.velocity.y < 0:
		player.velocity.y = -up_velocity_room_transition
	if player.velocity.y > 0:
		player.velocity.y = down_velocity_room_transition
	if player.animated_player_sprite.flip_h == true:
		player.velocity.x = horizontal_velocity_room_transition
	if player.animated_player_sprite.flip_h == false:
		player.velocity.x = -horizontal_velocity_room_transition
	player.get_state_machine().force_change_state(player.get_state_machine().no_control_state)
	player_control_regain.start()
	await player_control_regain.timeout
	player.get_state_machine().force_change_state(player.get_state_machine().idle_state)

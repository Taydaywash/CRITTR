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
var room_exited : bool = true

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
	#current_room = first_room
	#first_room.enter_room()

func entered_room(room : Room):
	next_room = room
	previous_room = current_room
	current_room = null
	fade_in = true
	fade_out = false
	room_transitioning = true
	set_enter_velocity()

func exited_room(_room : Room):
	room_exited = true

func respawn(respawn_pos : Vector2):
	fade_in = true
	fade_out = false
	respawn_position = respawn_pos
	respawning = true
func _process(delta: float) -> void:
	if fade_in:
		ui.increment_fade_in(delta, screen_fade_speed)
		if not ui.is_fading_in():
			fade_in = false
			screen_is_black = true
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
		if not ui.is_fading_out():
			player.get_camera().set_deferred("position_smoothing_enabled", true)
			fade_out = false

func transition_room():
	if previous_room == null:
		#print("previous_room error")
		previous_room = first_room
	if next_room == null:
		#print("next_room error")
		next_room = first_room
	previous_room.exit_room()
	current_room = next_room
	next_room.enter_room()
	next_room = null
func set_enter_velocity():
	call_deferred("set_enter_velocity_deferred")
func set_enter_velocity_deferred():
	player.get_state_machine().force_change_state(player.get_state_machine().no_control_state)
	var horizontal_axis = 0
	var jumping = false
	var falling = false
	if player.velocity.y < 0:
		jumping = true
	if player.animated_player_sprite.flip_h == true:
		horizontal_axis = -1
	if player.animated_player_sprite.flip_h == false:
		horizontal_axis = 1
	if player.velocity.y > 0:
		falling = true
	if falling and not (
		player.get_state_machine().last_state == player.get_state_machine().diving_state or 
		player.get_state_machine().last_state == player.get_state_machine().diving_falling_state):
		player.velocity.x = horizontal_velocity_room_transition * Input.get_axis("move_left","move_right")
	else:
		player.velocity.x = horizontal_velocity_room_transition * horizontal_axis
	if jumping  and not (
		player.get_state_machine().last_state == player.get_state_machine().diving_state or 
		player.get_state_machine().last_state == player.get_state_machine().diving_falling_state):
		player.velocity.y = -up_velocity_room_transition
	elif falling:
		player.velocity.y = down_velocity_room_transition
	var loop_counter = 0
	while room_exited == false:
		player_control_regain.start()
		await player_control_regain.timeout
		if room_exited == false:
			#print("failed to exit room: " + str(loop_counter))
			player.velocity.x = horizontal_velocity_room_transition * horizontal_axis
		loop_counter += 1
		if loop_counter > 4:
			room_exited = true
			#print("failed to exit room")
	room_exited = false
	if player.get_state_machine().last_state == player.get_state_machine().diving_state or player.get_state_machine().last_state == player.get_state_machine().diving_falling_state:
		player.get_state_machine().force_change_state(player.get_state_machine().diving_falling_state)
	else:
		player.get_state_machine().force_change_state(player.get_state_machine().idle_state)

extends Node
@export_category("References")
@export var ui: UI
@export var player: Player
var state_machine : StateMachine
@onready var up_ray: RayCast2D = $"../Player/RoomTransitionSides/up"
@onready var down_ray: RayCast2D = $"../Player/RoomTransitionSides/down"
@onready var left_ray: RayCast2D = $"../Player/RoomTransitionSides/left"
@onready var right_ray: RayCast2D = $"../Player/RoomTransitionSides/right"
@export_category("Parameters")
@export var starting_room : Room
@export var horizontal_enter_velocity : float
@export var horizontal_enter_multiplier : float
@export var minimum_enter_velocity : float
@export var up_enter_velocity : float
@export var up_enter_multiplier : float
@export var down_enter_velocity : float
@export var down_enter_multiplier : float
@export var horizontal_minimum_distance_from_last_room : float
@export var up_minimum_distance_from_last_room : float
@export var down_minimum_distance_from_last_room : float
@export var screen_fade_speed : float
@export var player_control_regain_delay : float

var player_control_regain : Timer
var current_room : Room = null
var previous_room : Room = null
var screen_is_black : bool = false
var state_controller
var fade_in = false
var fade_out = false
var transtiioning_room = false

var entering_from_below : bool = false
var entering_from_above : bool = false
var entering_from_right : bool = false
var entering_from_left : bool = false
var room_up : Room
var room_down : Room
var room_left : Room
var room_right : Room
var current_state : State
var exited_previous_room : bool = false

func _ready() -> void:
	state_machine = player.state_machine
	
	player_control_regain = Timer.new()
	player_control_regain.wait_time = player_control_regain_delay
	player_control_regain.one_shot = true
	self.add_child(player_control_regain)
	
	current_room = starting_room
	current_room.enter_room()

func entered_room(room : Room):
	if room == current_room:
		return
	exited_previous_room = false
	transtiioning_room = true
	fade_in = true
	
	room_up = player.up.get_collider().get_parent()
	room_down = player.down.get_collider().get_parent()
	room_left = player.left.get_collider().get_parent()
	room_right = player.right.get_collider().get_parent()
	transition_room()

func exited_room(_room : Room):
	exited_previous_room = true

func _process(delta: float) -> void:
	if fade_in:
		ui.increment_fade_in(delta,screen_fade_speed)
		if ui.screen_is_black():
			screen_is_black = true
			fade_in = false
	if screen_is_black:
		if transtiioning_room:
			change_room()
			fade_out = true
			transtiioning_room = false
		screen_is_black = false
	if fade_out:
		ui.increment_fade_out(delta,screen_fade_speed)
		if ui.screen_is_clear():
			fade_out = false

func _physics_process(_delta: float) -> void:
	var collision_point : Vector2
	if entering_from_below:
		if not exited_previous_room:
			player.velocity.y = -up_enter_velocity
			return
		if player.down.is_colliding():
			player.velocity.y = -up_enter_velocity
		else:
			entering_from_below = false
			return_to_state()
			reset_room_detection_rays()
	elif entering_from_above:
		if not exited_previous_room:
			player.velocity.y = down_enter_velocity
			return
		if player.up.is_colliding():
			pass
		else:
			entering_from_above = false
			return_to_state()
			reset_room_detection_rays()
	elif entering_from_right:
		if not exited_previous_room:
			player.velocity.x = -horizontal_enter_velocity
			return
		if player.right.is_colliding():
			collision_point = abs(player.right.to_local(player.right.get_collision_point()))
			player.velocity.x = -(abs(collision_point.x - horizontal_minimum_distance_from_last_room) + minimum_enter_velocity)
			player.velocity.x = player.velocity.x * horizontal_enter_multiplier
		else:
			entering_from_right = false
			return_to_state()
			reset_room_detection_rays()
	elif entering_from_left:
		if not exited_previous_room:
			player.velocity.x = horizontal_enter_velocity
			return
		if player.left.is_colliding():
			collision_point = abs(player.left.to_local(player.left.get_collision_point()))
			player.velocity.x = (abs(collision_point.x - horizontal_minimum_distance_from_last_room) + minimum_enter_velocity)
			player.velocity.x = player.velocity.x * horizontal_enter_multiplier
		else:
			entering_from_left = false
			return_to_state()
			reset_room_detection_rays()
	
func return_to_state():
	state_machine.force_change_state(state_machine.falling_state)

func change_room():
	previous_room.exit_room()
	current_room.enter_room()

func transition_room():
	current_state = state_machine.current_state
	state_machine.force_change_state(state_machine.no_control_state)
	set_up_room_detection_rays()
	previous_room = current_room
	if room_up != current_room:
		print("entering_from_below")
		current_room = room_up
		entering_from_below = true
	elif room_down != current_room:
		print("entering_from_above")
		current_room = room_down
		entering_from_above = true
	elif room_left != current_room:
		print("entering_from_right")
		current_room = room_left
		entering_from_right = true
	elif room_right != current_room:
		print("entering_from_left")
		current_room = room_right
		entering_from_left = true
	else:
		print("failed to find room")
		current_room = starting_room
		player.position = Vector2.ZERO

func set_up_room_detection_rays():
	player.up.hit_from_inside = false
	player.down.hit_from_inside = false
	player.left.hit_from_inside = false
	player.right.hit_from_inside = false
	player.down.target_position = Vector2(0,down_minimum_distance_from_last_room)
	player.up.target_position = Vector2(0,-up_minimum_distance_from_last_room)
	player.right.target_position = Vector2(horizontal_minimum_distance_from_last_room,0)
	player.left.target_position = Vector2(-horizontal_minimum_distance_from_last_room,0)

func reset_room_detection_rays():
	player.up.hit_from_inside = true
	player.down.hit_from_inside = true
	player.left.hit_from_inside = true
	player.right.hit_from_inside = true
	player.down.target_position = Vector2(0,1)
	player.up.target_position = Vector2(0,-1)
	player.right.target_position = Vector2(1,0)
	player.left.target_position = Vector2(-1,0)

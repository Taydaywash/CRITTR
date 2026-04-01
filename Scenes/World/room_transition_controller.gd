@icon("res://Assets/Editor Icons/Gear Icon.png")
extends Node
@export_category("Debug")
@export var starting_room : Room
@export var default_room : Room
@export_category("References")
@export var ui: UI
@export var player: Player
@export var audio_controller : AudioListener2D
@export var state_machine : StateMachine 
var current_room_detection_ray: RayCast2D
@export_group("Room Distance Rays","room_distance_detection_ray_")
@export var room_distance_detection_ray_up: RayCast2D
@export var room_distance_detection_ray_down: RayCast2D
@export var room_distance_detection_ray_left: RayCast2D
@export var room_distance_detection_ray_right: RayCast2D
@export_category("Parameters")
@export_group("Horizontal Enter","horizontal_enter_")
@export var horizontal_enter_velocity : float
@export var horizontal_enter_minimum_enter_velocity : float
@export var horizontal_enter_minimum_distance_from_last_room : float
@export var horizontal_enter_default_length : float
@export_group("Up Enter","up_enter_")
@export var up_enter_velocity : float
@export var up_enter_minimum_distance_from_last_room : float
@export var up_enter_default_length : float
@export_group("Down Enter","down_enter_")
@export var down_enter_velocity : float
@export var down_enter_minimum_distance_from_last_room : float
@export var down_enter_default_length : float
@export_group("Misc")
@export var screen_fade_out_speed : float
@export var screen_fade_in_speed : float
@export var player_control_regain_delay : float

var player_control_regain : Timer
var current_room : Room = null
var previous_room : Room = null
var screen_is_black : bool = false
var fade_to_black : bool = false
var fade_to_clear : bool = false
var transtioning_room : bool = false
var respawning : bool = false
var respawn_position : Vector2
var enter_direction : String = ""

var pre_transition_state : State
var pre_transition_velocity : Vector2
var entered_from_door : bool = false
var exited_previous_room : bool = false
var lock_screen_as_black : bool = true

var room_transition_failsafe_timer : Timer
@export var room_transition_failsafe_timer_wait_time : float

func _ready() -> void:
	await get_tree().process_frame
	current_room_detection_ray = player.current_room_detection_ray
	room_transition_failsafe_timer = Timer.new()
	room_transition_failsafe_timer.one_shot = true
	room_transition_failsafe_timer.wait_time = room_transition_failsafe_timer_wait_time
	add_child(room_transition_failsafe_timer)
	lock_screen_as_black = false
	if GameController.game_state.last_respawn_point:
		player.global_position = GameController.game_state.last_respawn_point
	elif starting_room:
		player.global_position = starting_room.get_respawn_point()
	else:
		player.global_position = default_room.get_respawn_point()
	#current_room = starting_room

func transition_room(room : Room): #called when entering room collider from room_controller.gd
	if lock_screen_as_black:
		return
	pre_transition_velocity = player.velocity
	pre_transition_state = state_machine.current_state
	if current_room:
		previous_room = current_room
	else:
		previous_room = current_room_detection_ray.get_collider().get_parent()
	enter_direction = get_enter_direction(room)
	if not enter_direction: #Entered from door or was spawned
		fade_to_black = true
		entered_from_door = true
		return
	state_machine.call_deferred("force_change_state", state_machine.no_control_no_gravity_state)
	set_up_room_detection_rays()
	transtioning_room = true
	room_transition_failsafe_timer.start()
	fade_to_black = true
	
func get_enter_direction(room : Room) -> String:
	dont_hit_from_inside()
	reset_room_detection_rays()
	if not room_distance_detection_ray_up.get_collider() and not room_distance_detection_ray_down.get_collider() and not room_distance_detection_ray_left.get_collider() and not room_distance_detection_ray_right.get_collider():
		return ""
	if room_distance_detection_ray_up.get_collider(): 
		if room_distance_detection_ray_up.get_collider().get_parent() == room:
			return "up"
	if room_distance_detection_ray_down.get_collider():
		if room_distance_detection_ray_down.get_collider().get_parent() == room:
			return "down"
	if room_distance_detection_ray_left.get_collider():
		if room_distance_detection_ray_left.get_collider().get_parent() == room:
			return "left"
	if room_distance_detection_ray_right.get_collider():
		if room_distance_detection_ray_right.get_collider().get_parent() == room:
			return "right"
	return ""

func dont_hit_from_inside():
	room_distance_detection_ray_up.hit_from_inside = false
	room_distance_detection_ray_down.hit_from_inside = false
	room_distance_detection_ray_left.hit_from_inside = false
	room_distance_detection_ray_right.hit_from_inside = false
	force_all_raycast_updates()
func hit_from_inside():
	room_distance_detection_ray_up.hit_from_inside = true
	room_distance_detection_ray_down.hit_from_inside = true
	room_distance_detection_ray_left.hit_from_inside = true
	room_distance_detection_ray_right.hit_from_inside = true
	force_all_raycast_updates()
	
func force_all_raycast_updates():
	room_distance_detection_ray_up.force_raycast_update()
	room_distance_detection_ray_down.force_raycast_update()
	room_distance_detection_ray_left.force_raycast_update()
	room_distance_detection_ray_right.force_raycast_update()
	
func respawn(respawn_pos):
	respawning = true
	fade_to_black = true
	respawn_position = respawn_pos

func _process(delta: float) -> void:
	if fade_to_black:
		ui.increment_fade_in(delta,screen_fade_in_speed)
		if ui.screen_is_black():
			EventController.emit_signal("screen_is_black")
			screen_is_black = true
			fade_to_black = false
		return
	if fade_to_clear:
		ui.increment_fade_out(delta,screen_fade_out_speed)
		if ui.screen_is_clear():
			fade_to_clear = false
		return
	if not screen_is_black:
		return
	if transtioning_room:
		return
	if respawning:
		player.set_deferred("position",respawn_position)
		state_machine.call_deferred("force_change_state", state_machine.spawning_state, false)
		respawning = false
		return
	if entered_from_door:
		finished_transitioning()
		entered_from_door = false
	screen_is_black = false
	fade_to_clear = true


func _physics_process(_delta: float) -> void:
	if not transtioning_room:
		exited_previous_room = false
		return
	if not is_ray_inside_previous_room() and not exited_previous_room:
		dont_hit_from_inside()
		exited_previous_room = true
	if not room_transition_failsafe_timer.time_left:
		finished_transitioning()
		return
	match enter_direction:
		"up":
			if not room_distance_detection_ray_down.is_colliding():
				finished_transitioning()
				return
			player.velocity.y = -up_enter_velocity
		"down":
			if not room_distance_detection_ray_up.is_colliding():
				finished_transitioning()
				return
			player.velocity.y = down_enter_velocity
		"left":
			if not room_distance_detection_ray_right.is_colliding():
				finished_transitioning()
				return
			player.velocity.y = 0
			player.velocity.x = -horizontal_enter_velocity
		"right":
			if not room_distance_detection_ray_left.is_colliding():
				finished_transitioning()
				return
			#var collision_point : Vector2 = abs(player.to_local(room_distance_detection_ray_left.get_collision_point()))
			player.velocity.y = 0
			player.velocity.x = horizontal_enter_velocity

func is_ray_inside_previous_room() -> bool:
	match enter_direction:
		"up":
			if room_distance_detection_ray_down.get_collider(): 
				if room_distance_detection_ray_down.get_collider().get_parent() == previous_room:
					return true
		"down":
			if room_distance_detection_ray_up.get_collider():
				if room_distance_detection_ray_up.get_collider().get_parent() == previous_room:
					return true
		"left":
			if room_distance_detection_ray_right.get_collider():
				if room_distance_detection_ray_right.get_collider().get_parent() == previous_room:
					return true
		"right":
			if room_distance_detection_ray_left.get_collider():
				if room_distance_detection_ray_left.get_collider().get_parent() == previous_room:
					return true
	return false

func finished_transitioning():
	room_transition_failsafe_timer.stop()
	transtioning_room = false
	return_to_state()
	current_room_detection_ray.force_raycast_update()
	current_room_detection_ray.hit_from_inside = true
	if current_room_detection_ray.get_collider(): 
		current_room = current_room_detection_ray.get_collider().get_parent()
	if previous_room == current_room:
		previous_room = default_room
	previous_room.exit_room()
	current_room.enter_room()

func return_to_state():
	player.set_deferred("velocity", Vector2.ZERO)
	await get_tree().create_timer(player_control_regain_delay).timeout
	player.set_deferred("velocity", pre_transition_velocity)
	state_machine.call_deferred("force_change_state",pre_transition_state)

func set_up_room_detection_rays():
	room_distance_detection_ray_up.target_position = Vector2(0, -down_enter_minimum_distance_from_last_room)
	room_distance_detection_ray_down.target_position = Vector2(0, up_enter_minimum_distance_from_last_room)
	room_distance_detection_ray_left.target_position = Vector2(-horizontal_enter_minimum_distance_from_last_room, 0)
	room_distance_detection_ray_right.target_position = Vector2(horizontal_enter_minimum_distance_from_last_room, 0)
	hit_from_inside()

func reset_room_detection_rays():
	room_distance_detection_ray_up.target_position = Vector2(0, -down_enter_default_length)
	room_distance_detection_ray_down.target_position = Vector2(0, up_enter_default_length)
	room_distance_detection_ray_left.target_position = Vector2(-horizontal_enter_default_length, 0)
	room_distance_detection_ray_right.target_position = Vector2(horizontal_enter_default_length, 0)
	force_all_raycast_updates()

func play_music(music : AudioStream):
	audio_controller.play_music(music)

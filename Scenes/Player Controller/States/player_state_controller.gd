class_name Player
extends CharacterBody2D

@export var state_machine : StateMachine
@export var camera : Camera2D
@export_category("Room Transition Direction Rays")
@export var up : RayCast2D
@export var down : RayCast2D
@export var left : RayCast2D
@export var right : RayCast2D
@export_category("Parameters")
@export var normal_gravity : int
@export var max_falling_speed : int
@export var max_stuck_time : float
@export_category("References")
@export var animated_player_sprite: AnimatedSprite2D
@export var audio_controller_reference : AudioController
@export var particle_controller_reference : ParticleController
@export var respawn_controller_reference : Node
@export var trigger_hitbox : Area2D

var stuck_timer : Timer
var global_position_last_frame : Vector2 = Vector2.ZERO
var checking_if_stuck : bool = false

func _ready() -> void:
	EventController.connect("collectable_grabbed",func collectable_following(id):
		EventController.emit_signal("collectable_following",id,self)
		)
	stuck_timer = Timer.new()
	stuck_timer.one_shot = true
	stuck_timer.wait_time = max_stuck_time
	add_child(stuck_timer)
	state_machine.initialize(self,animated_player_sprite)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	check_if_stuck()
	global_position_last_frame = global_position

func _process(delta: float) -> void:
	if velocity.x < 0:
		animated_player_sprite.flip_h = true
	elif velocity.x > 0:
		animated_player_sprite.flip_h = false
	else:
		var horizontal_input = Input.get_axis("move_left","move_right")
		match horizontal_input:
			-1:
				animated_player_sprite.flip_h = true
			1: 
				animated_player_sprite.flip_h = false
	
	state_machine.process_frame(delta)

@warning_ignore("shadowed_variable_base_class")
func play_animation(name):
	if name == "":
		animated_player_sprite.play("no animation")
	else:
		assert(animated_player_sprite.sprite_frames.has_animation(name),"Animation not found: Ensure that name is typed correctly and that the animation exists!")
		animated_player_sprite.play(name)

func _on_tileset_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		EventController.emit_signal("on_hidden_tile_entered",body)

func check_if_stuck() -> void:
	if state_machine.current_state == state_machine.idle_state or state_machine.current_state == state_machine.idle_crouching_state:
		stuck_timer.stop()
		checking_if_stuck = false
		return
	if global_position_last_frame != global_position:
		stuck_timer.stop()
		checking_if_stuck = false
		return
	if not checking_if_stuck:
		stuck_timer.start()
		checking_if_stuck = true
		return
	if not stuck_timer.time_left:
		respawn_controller_reference.trigger_respawn()
		checking_if_stuck = false
		return

func can_collect() -> bool:
	if not is_on_floor():
		return false
	if trigger_hitbox.has_overlapping_areas():
		for area in trigger_hitbox.get_overlapping_areas():
			if area is PickupBlocker:
				return false
	return true

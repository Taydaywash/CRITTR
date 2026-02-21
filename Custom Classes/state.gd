@icon("res://Assets/Editor Icons/State Icon.png")
class_name State
extends Node

@export var animation_name : String
@export var placeholder_animation_color : Color

@export_category("Audio")
@export_group("Enter sound","enter_")
@export var enter_sounds : Array[AudioStream]
@export var enter_pitch_low : float = 0.7
@export var enter_pitch_high : float = 1.3
@export_group("While in state sound","while_in_state_")
@export var while_in_state_sounds : Array[AudioStream]
@export var while_in_state_sound_low : float = 0.7
@export var while_in_state_sound_high : float = 1.3
@export var while_in_state_repeat_after_seconds: float = 0
@export_group("Exit Sound","exit_")
@export var exit_sounds : Array[AudioStream]
@export var exit_pitch_low : float = 0.7
@export var exit_pitch_high : float = 1.3
@export var exit_excluded_states : Array[State]
@export_group("Exit Sound/When entering state, play sound","exit_when_entering_state_")
#exported typed dictionaries cause editor crashes, so linked lists are used instead
@export var exit_when_entering_state_state : Array[State]
@export var exit_when_entering_state_play_sound : Array[AudioStream]
@export var exit_when_entering_state_pitch_low : Array[float] = [1.0]
@export var exit_when_entering_state_pitch_high : Array[float] = [1.0]

var player : Player
var audio_manager : AudioListener2D
var sprite : AnimatedSprite2D
var colliders : Array[CollisionShape2D]
var audio_loop_timer : Timer

func set_direction(_direction : String) -> void:
	pass

func activate(_last_state : State) -> void:
	#Reparents Rays to player so that they follow the player
	for child in get_children():
		if child.get_class() == "RayCast2D":
			child.reparent(player, false)
		if child is Area2D: 
			child.reparent(player, false)
	#replace parent.modulate with this once animations are added
	if enter_sounds:
		audio_manager.play_sound(enter_sounds.pick_random(),enter_pitch_low,enter_pitch_high)
	player.play_animation(animation_name)
	player.modulate = placeholder_animation_color
	if while_in_state_sounds:
		loop_sound()

func process_input(_event) -> State:
	return null

func process_physics(_delta) -> State:
	return null

func process_frame(_delta) -> State:
	return null

func change_collider_to(new_collider : CollisionShape2D) -> void:
	for collider in colliders:
		if collider == new_collider:
			collider.set_deferred("disabled" , false)
		else:
			collider.set_deferred("disabled" , true)

func deactivate(next_state : State) -> void:
	sprite.scale.y = 1
	sprite.scale.x = 1
	sprite.rotation = 0
	if audio_loop_timer:
		audio_loop_timer.queue_free()
	if exit_when_entering_state_state.has(next_state):
		var state_index = exit_when_entering_state_state.find(next_state)
		audio_manager.play_sound(exit_when_entering_state_play_sound[state_index],
		exit_when_entering_state_pitch_low[state_index],exit_when_entering_state_pitch_high[state_index])
		return
	if (next_state not in exit_excluded_states) and exit_sounds:
		audio_manager.play_sound(exit_sounds.pick_random(),exit_pitch_low,exit_pitch_high)
	return

func loop_sound() -> void:
	audio_loop_timer = Timer.new()
	add_child(audio_loop_timer)
	audio_loop_timer.wait_time = while_in_state_repeat_after_seconds
	audio_loop_timer.start()
	while audio_loop_timer:
		audio_manager.play_sound(while_in_state_sounds.pick_random(), while_in_state_sound_low, while_in_state_sound_high)
		await audio_loop_timer.timeout
		audio_loop_timer.start()

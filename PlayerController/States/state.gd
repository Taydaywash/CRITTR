class_name State
extends Node

@export
var animation_name : String
@export
var placeholder_animation_color : Color

var parent : CharacterBody2D

func set_direction(_direction : String) -> void:
	pass

func activate(_last_state : State) -> void:
	#replace parent.modulate with this once animations are added
	#parent.animations.play(animation_name)
	parent.modulate = placeholder_animation_color

func process_input(_event) -> State:
	return null

func process_physics(_delta) -> State:
	return null

func process_frame(_delta) -> State:
	return null

func deactivate() -> void:
	pass

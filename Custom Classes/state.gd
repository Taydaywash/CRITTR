class_name State
extends Node

@export
var animation_name : String
@export
var placeholder_animation_color : Color

var parent : CharacterBody2D
var sprite : AnimatedSprite2D
var colliders : Dictionary[String,CollisionShape2D]

func set_direction(_direction : String) -> void:
	pass

func activate(_last_state : State) -> void:
	#replace parent.modulate with this once animations are added
	parent.play_animation(animation_name)
	parent.modulate = placeholder_animation_color

func process_input(_event) -> State:
	return null

func process_physics(_delta) -> State:
	return null

func process_frame(_delta) -> State:
	return null

func change_collider_to(new_collider : CollisionShape2D) -> void:
	for collider : String in colliders:
		if colliders[collider] == new_collider:
			colliders[collider].disabled = false
		else:
			colliders[collider].disabled = true

func deactivate(_next_state : State) -> void:
	sprite.scale.y = 1
	sprite.scale.x = 1
	sprite.rotation = 0

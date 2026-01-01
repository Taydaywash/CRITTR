class_name State
extends Node

@export
var animation_name : String
@export
var placeholder_animation_color : Color

var player : Player
var sprite : AnimatedSprite2D
var colliders : Array[CollisionShape2D]

func set_direction(_direction : String) -> void:
	pass

func activate(_last_state : State) -> void:
	#Reparents Rays to player so that they follow the player
	for child in get_children():
		if child.get_class() == "RayCast2D":
			child.reparent(player, false)
	#replace parent.modulate with this once animations are added
#	parent.play_sound()
	player.play_animation(animation_name)
	player.modulate = placeholder_animation_color

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

func deactivate(_next_state : State) -> void:
	sprite.scale.y = 1
	sprite.scale.x = 1
	sprite.rotation = 0

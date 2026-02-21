@icon("res://Assets/Editor Icons/Gear Icon.png")
extends Node

@onready var room_transition_controller : Node = $"../../Rooms"
@export var player : Player
@export var ground_distance_ray : RayCast2D

var respawn_position : Vector2

func _on_body_entered(_body: Node2D) -> void:
	player.velocity = Vector2(0,0)
	player.state_machine.change_state(player.state_machine.death_state,null)
	await get_tree().create_timer(0.5).timeout
	room_transition_controller.respawn(respawn_position)

func _on_trigger_hitbox_area_entered(area: Area2D) -> void:
	if area.collision_layer == 4:
		if ground_distance_ray.is_colliding():
			respawn_position = Vector2(area.global_position.x,ground_distance_ray.get_collision_point().y - 80)
		#respawn_position = area.global_position

func _on_respawn_timer_timeout() -> void:
	player.set_deferred("position",respawn_position)

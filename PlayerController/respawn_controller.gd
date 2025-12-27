extends Node

@onready var rooms : Node = $"../../Rooms"
@onready var player : CharacterBody2D = $".."

var respawn_position : Vector2

func _on_body_entered(_body: Node2D) -> void:
	player.velocity = Vector2(0,0)
	player.get_state_machine().change_state(player.get_state_machine().no_control_state,null)
	rooms.respawn(respawn_position)

func _on_trigger_hitbox_area_entered(area: Area2D) -> void:
	if area.collision_layer == 4:
		respawn_position = area.global_position

func _on_respawn_timer_timeout() -> void:
	player.set_deferred("position",respawn_position)

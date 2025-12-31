extends Node

@onready var room_transition_controller : Node = $"../../Rooms"
@onready var player : Player = $".."

var respawn_position : Vector2

func _on_body_entered(_body: Node2D) -> void:
	player.velocity = Vector2(0,0)
	player.state_machine.change_state(player.state_machine.death_state,null)
	await get_tree().create_timer(0.5).timeout
	room_transition_controller.respawn(respawn_position)

func _on_trigger_hitbox_area_entered(area: Area2D) -> void:
	if area.collision_layer == 4:
		respawn_position = area.global_position

func _on_respawn_timer_timeout() -> void:
	player.set_deferred("position",respawn_position)

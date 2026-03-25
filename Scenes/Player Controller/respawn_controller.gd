@icon("res://Assets/Editor Icons/Gear Icon.png")
extends Node

@onready var room_transition_controller : Node = $"../../Rooms"
@export var player : Player
@export var ground_distance_ray : RayCast2D
@export var player_respawn_wait_time : float

var respawn_position : Vector2

func _ready() -> void:
	EventController.connect("player_death", trigger_respawn)

func _on_body_entered(_body: Node2D) -> void:
	EventController.emit_signal("player_death")

func _on_trigger_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is RespawnPoint:
		print("respawn")
		respawn_position = area.get_parent().get_respawn_point()

func trigger_respawn() -> void:
	player.modulate = Color.WHITE
	player.velocity = Vector2(0,0)
	player.state_machine.change_state(player.state_machine.death_state,null)
	await get_tree().create_timer(player_respawn_wait_time).timeout
	room_transition_controller.respawn(respawn_position)
	EventController.emit_signal("player_respawn")

func _on_respawn_timer_timeout() -> void:
	player.set_deferred("position",respawn_position)

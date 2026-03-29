extends Area2D

@export var camera_offset : Vector2
@onready var room = $".."

func _on_body_entered(_body: Node2D) -> void:
	room.player.camera.position = camera_offset

extends Area2D

@export var camera_offset : Vector2
@onready var room = $".."
var lock_camera_offset : bool = false

func _process(_delta: float) -> void:
	if lock_camera_offset:
		room.player.camera.position = camera_offset

func _on_body_entered(_body: Node2D) -> void:
	lock_camera_offset = true

func _on_body_exited(_body: Node2D) -> void:
	lock_camera_offset = false
	room.player.camera.position = Vector2.ZERO

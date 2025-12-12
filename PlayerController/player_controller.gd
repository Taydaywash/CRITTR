extends Node2D

var walk_speed = 10

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_right"):
		print("Right Pressed")

extends Area2D

@export var id: int = -1

func _on_body_entered(body):
	if body is Player:
		EventController.emit_signal("update_sequence", id)
		print(id)

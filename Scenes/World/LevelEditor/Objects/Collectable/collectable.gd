class_name Collectable
extends Node2D

@export var value: int = 1
@export var room_name: String = ""
var id: String = ""

func _ready() -> void: 
	if room_name == "":
		room_name = get_parent().name
	id = "%s_collectable_%s_%s" % [room_name, global_position.x, global_position.y]
	if GameController.is_collected(id):
		queue_free()
		return

func _on_body_entered(body):
	if body is Player:
		EventController.emit_signal("collectable_collected", id, value)
		queue_free()

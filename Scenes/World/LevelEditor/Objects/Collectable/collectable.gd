class_name Collectable
extends Node2D

@export var value: int = 1
@export var room_name: String = ""
var id: String = ""

func _ready() -> void: 
	if room_name == "":
		room_name = get_tree().current_scene.name
	id = "%s_collectable_%s_%s" % [room_name, global_position.x, global_position.y]
	if GameController.is_collected(id):
		queue_free()
		return

func _on_body_entered(body):
	if body is Player:
		GameController.collectable_collected(id, value)
		queue_free()

#func print_statement(value: int):
	#print("collected", value)

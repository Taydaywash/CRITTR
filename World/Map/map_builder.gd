extends Node2D

@onready var rooms_manager = get_node("/root/World/Rooms")

func _ready() -> void:
	for child in rooms_manager.get_children():
		if child.get_class() == "Node":
			for room in child.get_children():
				if room.get_class() == "Node2D" and room.hide_from_map == false:
					room.get_node("Area2D/LevelBounds").shape.get_rect()
					
func _draw() -> void:
	pass

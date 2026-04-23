@icon("res://Assets/Editor Icons/Region Icon.png")
class_name Region
extends Node

@export var music : AudioStream
@export_color_no_alpha var map_color : Color
@onready var region_background = get_child(0)
var region_visited : bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug Menu"):
		region_visited = true

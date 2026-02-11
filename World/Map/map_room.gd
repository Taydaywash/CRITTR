class_name MapRoom
extends Polygon2D

@export var outline : Line2D
@export_category("Map Render Paremeters")
@export var outline_thickness : float
@export_category("Current Room")
@export_color_no_alpha var current_room_color : Color
@export_color_no_alpha var current_room_outline_color : Color
@export_category("Visited Room")
@export_color_no_alpha var visited_room_color : Color
@export_color_no_alpha var visited_room_outline_color : Color
@export_category("Not Visited Room")
@export_color_no_alpha var not_visited_room_color : Color
@export_color_no_alpha var not_visited_room_outline_color : Color
@export_category("Hidden Room")
@export var visited_hidden_room_color : Color
@export var visited_hidden_room_outline_color : Color
@export var current_hidden_room_color : Color
@export var current_hidden_room_outline_color : Color

var corresponding_room : Room = null

func _process(_delta: float) -> void:
	outline.width = outline_thickness
	if corresponding_room:
		if corresponding_room.room_transition_controller.current_room == corresponding_room:
			color = current_room_color
			outline.default_color = current_room_outline_color
		else:
			if corresponding_room.room_visited:
				color = visited_room_color
				outline.default_color = visited_room_outline_color
			else:
				color = not_visited_room_color
				outline.default_color = not_visited_room_outline_color
		if corresponding_room.hidden_room:
			outline.default_color = current_hidden_room_outline_color
			outline.default_color.a = 0.0
			color.a = 0.0
			if corresponding_room.room_visited:
				color = visited_hidden_room_color
				outline.default_color = visited_hidden_room_outline_color
			if corresponding_room.room_transition_controller.current_room == corresponding_room:
				color = current_hidden_room_color

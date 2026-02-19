class_name MapRoom
extends Polygon2D

@export var outline : Line2D
@export_category("Map Render Paremeters")
@export var outline_thickness : int
@export_category("Current Room")
@export_color_no_alpha var current_room_color : Color
@export var outline_darkness : float
@export_category("Not Visited Room")
@export var not_visited_room_darkness : float = 1
@export_category("Hidden Room")
@export var visited_hidden_room_color : Color
@export var visited_hidden_room_outline_color : Color
@export var current_hidden_room_color : Color
@export var current_hidden_room_outline_color : Color

var map_controller = null
var corresponding_room : Room = null
var corresponding_region : Region

func _process(_delta: float) -> 	void:
	if map_controller:
		if not map_controller.show_regions:
			visible = true
		else:
			visible = false
	if not corresponding_room:
		return
	outline.width = outline_thickness
	outline.default_color = color - Color(outline_darkness,outline_darkness,outline_darkness,0.0)
	
	if corresponding_room.room_transition_controller.current_room == corresponding_room: #if in room
		if corresponding_room.hidden_room: 
			color = current_hidden_room_color
		else: 
			color = current_room_color
	else:
		if corresponding_room.room_visited: 
			if corresponding_room.hidden_room:
				color = visited_hidden_room_color
				outline.default_color.a = 0.1
			else:
				color = corresponding_region.map_color
		else:
			if corresponding_room.hidden_room:
				outline.default_color = current_hidden_room_outline_color
				outline.default_color.a = 0.0
				color.a = 0.0
			else:
				color = corresponding_region.map_color - Color(not_visited_room_darkness,not_visited_room_darkness,not_visited_room_darkness,0.0)

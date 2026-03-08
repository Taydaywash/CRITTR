class_name MapRoom
extends Polygon2D

@export var outline : Line2D
@export var collider : CollisionShape2D
@export_category("Map Render Paremeters")
@export var outline_thickness : int
@export_color_no_alpha var hovered_outline_color : Color
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
@export_category("Room icons")
@export var collectible_icon : Sprite2D
@export var save_point_icon : Sprite2D
@export var crittr_icon : Sprite2D

var map_controller = null
var corresponding_room : Room = null
var corresponding_region : Region

func _process(_delta: float) -> void:
	if not corresponding_room:
		return
	
	collectible_icon.position.x = int(corresponding_room.has_save_point) * -1500
	collectible_icon.visible = corresponding_room.room_visited
	save_point_icon.visible = corresponding_room.room_visited
	if not corresponding_room.has_collectible:
		collectible_icon.visible = false
	if not corresponding_room.has_save_point:
		save_point_icon.visible = false
	outline.width = outline_thickness
	outline.default_color = color - Color(outline_darkness,outline_darkness,outline_darkness,0.0)
	if map_controller:
		if map_controller.show_regions:
			visible = false
		else:
			visible = true
			
		if map_controller.hovered_room == self:
			outline.default_color = hovered_outline_color
			z_index = 1
		else:
			outline.default_color = color - Color(outline_darkness,outline_darkness,outline_darkness,0.0)
			z_index = 0
	if corresponding_room.room_transition_controller.current_room == corresponding_room: #if in room
		if not corresponding_room.hidden_room: 
			color = current_room_color
			return
		color = current_hidden_room_color
		return
	if corresponding_room.room_visited: 
		if not corresponding_room.hidden_room:
			color = corresponding_region.map_color
			return
		color = visited_hidden_room_color
		outline.default_color.a = 0.1
		return
	if not corresponding_room.hidden_room:
		color = corresponding_region.map_color - Color(not_visited_room_darkness,not_visited_room_darkness,not_visited_room_darkness,0.0)
		return
	outline.default_color = current_hidden_room_outline_color
	outline.default_color.a = 0.0
	color.a = 0.0

extends Node2D

@export_category("Parameters")
@export var camera_move_speed : int
@export var camera_zoom_speed : float
@export var default_zoom : float
@export var max_zoom : float
@export var min_zoom : float
@export var region_show_zoom : float
@export_category("References")
@onready var pause_screen = get_parent()
@export var not_focused_overlay : Polygon2D
@export var camera : Camera2D
@export var viewport : SubViewport
@export var viewport_container : SubViewportContainer
@export var player : Player
@export var rooms_manager : Node

@onready var base_map_room = preload("uid://p60bcylp36uc")
@onready var base_map_reigon = preload("uid://bu6n1yqvtd2vk")
@onready var map_region_shape = preload("uid://ofnyj0qnl8mi")

@export var current_region : Region
var show_regions : bool = false

func show_map(should_show : bool) -> void:
	if should_show and not viewport_container.visible:
		camera.position = rooms_manager.current_room.global_position
		camera.zoom = Vector2(default_zoom,default_zoom)
	viewport_container.visible = should_show

func _ready() -> void:
	for child in rooms_manager.get_children():
		if child.get_class() == "Node": #If child is a region
			for room in child.get_children(): 
				var region_instance = base_map_reigon.instantiate()
				viewport.add_child(region_instance)
				region_instance.corresponding_region = child
				region_instance.map_controller = self
				if room.get_class() == "Node2D" and room.interior_room == false: #Rooms setup
					var room_shape : PackedVector2Array
					var region_collider_shape : PackedVector2Array
					var room_rect : Rect2 = room.get_node("Area2D/LevelBounds").shape.get_rect()
					var room_instance = base_map_room.instantiate()
					var map_region_part = map_region_shape.instantiate()
					
					viewport.add_child(room_instance)
					room_instance.corresponding_region = child
					room_instance.map_controller = self
					room_instance.corresponding_room = room

					room_instance.global_position = room.global_position
					map_region_part.global_position = room.global_position
					
					room_shape.append(room_rect.position) #Top left corner
					room_shape.append(Vector2(room_rect.end.x,room_rect.position.y)) #Top right corner
					room_shape.append(room_rect.end) #Bottom right corner
					room_shape.append(Vector2(room_rect.position.x,room_rect.end.y)) #Bottom Left corner
					
					region_collider_shape.append(room_rect.position + Vector2(-100,-100)) #Top left corner
					region_collider_shape.append(Vector2(room_rect.end.x + 100,room_rect.position.y - 100)) #Top right corner
					region_collider_shape.append(room_rect.end + Vector2(100,100)) #Bottom right corner
					region_collider_shape.append(Vector2(room_rect.position.x - 100,room_rect.end.y + 100)) #Bottom Left corner
					
					room_instance.polygon = room_shape
					room_instance.uv = room_shape
					room_instance.outline.width = 10
					room_instance.outline.points = room_shape
					
					map_region_part.polygon = region_collider_shape
					map_region_part.region_shape.polygon = room_shape
					map_region_part.region_shape.uv = room_shape
					map_region_part.outline.width = 200
					map_region_part.outline.points = region_collider_shape
					map_region_part.map_controller = self
					map_region_part.corresponding_region = child
					if not room_instance.corresponding_room.hidden_room:
						region_instance.add_child(map_region_part)

func _process(_delta: float) -> void:
	if pause_screen.map_tab.default_focus.has_focus():
		not_focused_overlay.visible = false
		not_focused_overlay.get_child(0).visible = false
		if camera.zoom < Vector2(region_show_zoom,region_show_zoom):
			show_regions = true
		else:
			show_regions = false
		if Input.is_action_pressed("zoom_in"):
			if camera.zoom < Vector2(max_zoom,max_zoom):
				camera.zoom += Vector2(camera_zoom_speed,camera_zoom_speed)
		if Input.is_action_pressed("zoom_out"):
			if camera.zoom > Vector2(min_zoom,min_zoom):
				camera.zoom -= Vector2(camera_zoom_speed,camera_zoom_speed)
		if Input.is_action_pressed("move_up"):
			camera.position.y -= camera_move_speed / (camera.zoom.x * 10)
		if Input.is_action_pressed("move_down"):
			camera.position.y += camera_move_speed / (camera.zoom.x * 10)
		if Input.is_action_pressed("move_left"):
			camera.position.x -= camera_move_speed / (camera.zoom.x * 10)
		if Input.is_action_pressed("move_right"):
			camera.position.x += camera_move_speed / (camera.zoom.x * 10)
	else:
		camera.position = rooms_manager.current_room.global_position
		camera.zoom = Vector2(default_zoom,default_zoom)
		not_focused_overlay.visible = true
		not_focused_overlay.get_child(0).visible = true

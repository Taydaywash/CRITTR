extends Node2D

@export_category("Parameters")
@export var camera_move_speed : int
@export var outline_width : int
@export_category("References")
@export var camera : Camera2D
@export var viewport : SubViewport
@export var viewport_container : SubViewportContainer
@export var player : Player
@export var rooms_manager : Node

@onready var base_map_room = preload("uid://p60bcylp36uc")
@onready var base_map_reigon = preload("uid://bu6n1yqvtd2vk")

func show_map(should_show : bool) -> void:
	if should_show and not viewport_container.visible:
		camera.position = rooms_manager.current_room.global_position
	viewport_container.visible = should_show

func _ready() -> void:
	for child in rooms_manager.get_children():
		if child.get_class() == "Node":
			for room in child.get_children():
				if room.get_class() == "Node2D" and room.interior_room == false:
					var room_shape : PackedVector2Array
					var room_rect : Rect2 = room.get_node("Area2D/LevelBounds").shape.get_rect()
					var room_polygon = base_map_room.instantiate()
					var room_outline = room_polygon.outline
					viewport.add_child(room_polygon)
					room_polygon.global_position =  room.global_position
					room_polygon.corresponding_room = room
					
					room_shape.append(room_rect.position) #Top left corner
					room_shape.append(Vector2(room_rect.end.x,room_rect.position.y)) #Top right corner
					room_shape.append(room_rect.end) #Bottom right corner
					room_shape.append(Vector2(room_rect.position.x,room_rect.end.y)) #Bottom Left corner
					
					room_polygon.polygon = room_shape
					room_polygon.uv = room_shape
					room_outline.width = outline_width
					room_outline.points = room_shape

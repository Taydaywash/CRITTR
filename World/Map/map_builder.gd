extends Node2D

@onready var rooms_manager = get_node("/root/World/Rooms")
@export var camera : Camera2D
@export var camera_move_speed : int
@export var viewport : Window

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Debug Menu"):
		viewport.visible = !viewport.visible

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		camera.position.y -= camera_move_speed
	if Input.is_action_pressed("move_down"):
		camera.position.y += camera_move_speed
	if Input.is_action_pressed("move_left"):
		camera.position.x -= camera_move_speed
	if Input.is_action_pressed("move_right"):
		camera.position.x += camera_move_speed

func _ready() -> void:
	for child in rooms_manager.get_children():
		if child.get_class() == "Node":
			for room in child.get_children():
				if room.get_class() == "Node2D" and room.hide_from_map == false:
					var room_shape : PackedVector2Array
					var room_rect : Rect2 = room.get_node("Area2D/LevelBounds").shape.get_rect()
					var room_polygon := Polygon2D.new()
					var room_outline := Line2D.new()
					viewport.add_child(room_polygon)
					room_polygon.add_child(room_outline)
					room_outline.closed =  true
					room_outline.default_color = Color.BLACK
					room_outline.width = 100
					
					room_polygon.global_position =  room.global_position
					room_shape.append(room_rect.position) #Top left corner
					room_shape.append(Vector2(room_rect.end.x,room_rect.position.y)) #Top right corner
					room_shape.append(room_rect.end) #Bottom right corner
					room_shape.append(Vector2(room_rect.position.x,room_rect.end.y)) #Bottom Left corner
					room_polygon.polygon = room_shape
					room_polygon.uv = room_shape
					room_outline.points = room_shape
	
func _draw() -> void:
	pass

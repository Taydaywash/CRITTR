class_name room
extends Node2D

#World coordinates are used to transition between rooms
#The center is (0,0) the coordinate increases for each room traveled
@onready var camera_bounds: CollisionShape2D = $CameraBounds
@export var world_coordinates : Vector2

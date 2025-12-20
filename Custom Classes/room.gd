class_name Room
extends Node2D

#World coordinates are used to transition between rooms
#The center is (0,0) the coordinate increases for each room traveled
@onready var level_bounds: CollisionShape2D = $Area2D/LevelBounds
@export var world_coordinates : Vector2
@export var camera_zoom : float

var player: CharacterBody2D
var player_camera : Camera2D
var camera_boundary_top_left
var camera_boundary_bottom_right

var bounds : Dictionary = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0
}

func change_camera_bounds() -> void:
	player = $"../../PlayerController"
	player_camera = player.get_camera()
	camera_boundary_top_left = level_bounds.shape.get_rect().position
	camera_boundary_bottom_right = level_bounds.shape.get_rect().end
	player_camera.change_zoom_to(camera_zoom)
	set_camera_bounds()

func set_camera_bounds():
	bounds.top = camera_boundary_top_left.y + level_bounds.position.y + self.position.y
	bounds.bottom = camera_boundary_bottom_right.y + level_bounds.position.y + self.position.y
	bounds.left = camera_boundary_top_left.x + level_bounds.position.x + self.position.x
	bounds.right = camera_boundary_bottom_right.x + level_bounds.position.x + self.position.x
	player_camera.change_bounds_to(bounds)

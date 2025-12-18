extends room

var camera_upper_bound : int
var camera_lower_bound : int
var camera_left_bound : int
var camera_right_bound : int
@onready var player: CharacterBody2D = $"../../PlayerController"
var bounds : Dictionary = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0
}

func _ready() -> void:
	var player_camera : Camera2D = player.get_camera()
	var camera_boundary_top_left = camera_bounds.shape.get_rect().position
	var camera_boundary_bottom_right = camera_bounds.shape.get_rect().end
	bounds.top = camera_boundary_top_left.y + camera_bounds.position.y
	bounds.bottom = camera_boundary_bottom_right.y + camera_bounds.position.y
	bounds.left = camera_boundary_top_left.x - camera_bounds.position.x
	bounds.right = camera_boundary_bottom_right.x - camera_bounds.position.x 
	player_camera.change_bounds_to(bounds)

class_name Room
extends Node2D

@export var camera_zoom : float
@export var zoom_to_fit : bool

@onready var room_transition_controller: Node = $"../.."
@onready var level_bounds: CollisionShape2D = $Area2D/LevelBounds
@onready var player: Player = $"../../../Player"
var camera_boundary_top_left
var camera_boundary_bottom_right

#Camera Bounds defined by the Level Bounds collision shape in each room
var bounds : Dictionary = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0
}

func _entered_room_collider(_body: Node2D) -> void:
	room_transition_controller.entered_room(self)
func _exited_room_collider(_body: Node2D) -> void:
	room_transition_controller.exited_room(self)

func enter_room():
	change_camera_bounds()
	z_index = 1
func exit_room():
	z_index = 0

func change_camera_bounds(snap_camera : bool = false, zoom : float = camera_zoom) -> void:
	camera_boundary_top_left = level_bounds.shape.get_rect().position
	camera_boundary_bottom_right = level_bounds.shape.get_rect().end
	if snap_camera:
		player.camera.position_smoothing_enabled = false
	if zoom:
		player.camera.change_zoom_to(player.camera.default_zoom * camera_zoom)
	else:
		player.camera.change_zoom_to(player.camera.default_zoom)
	if zoom_to_fit:
		player.camera.change_zoom_to(get_viewport_rect().size.x/level_bounds.shape.get_rect().size.x)
		if player.camera.zoom.y <= get_viewport_rect().size.y/level_bounds.shape.get_rect().size.y:
			player.camera.change_zoom_to(get_viewport_rect().size.y/level_bounds.shape.get_rect().size.y)
	else:
		var zoom_to_fit_zoom
		zoom_to_fit_zoom = get_viewport_rect().size.x/level_bounds.shape.get_rect().size.x
		if player.camera.zoom.y <= get_viewport_rect().size.y/level_bounds.shape.get_rect().size.y:
			zoom_to_fit_zoom = get_viewport_rect().size.y/level_bounds.shape.get_rect().size.y
		if zoom_to_fit_zoom > player.camera.zoom.x:
			player.camera.change_zoom_to(zoom_to_fit_zoom)
	bounds.top = camera_boundary_top_left.y + level_bounds.position.y + self.position.y
	bounds.bottom = camera_boundary_bottom_right.y + level_bounds.position.y + self.position.y
	bounds.left = camera_boundary_top_left.x + level_bounds.position.x + self.position.x
	bounds.right = camera_boundary_bottom_right.x + level_bounds.position.x + self.position.x
	player.camera.change_bounds_to(bounds)
	if snap_camera:
		player.camera.position_smoothing_enabled = true

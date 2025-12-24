class_name Room
extends Node2D

@export var camera_zoom : float

@onready var default_player_camera_reference: Camera2D = $defaultPlayerCameraReference
@onready var world_controller: Node = $"../.."
@onready var level_bounds: CollisionShape2D = $Area2D/LevelBounds
var player: CharacterBody2D
var player_camera : Camera2D
var camera_boundary_top_left
var camera_boundary_bottom_right

#Camera Bounds defined by the Level Bounds collision shape in each room
var bounds : Dictionary = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0
}

func _ready() -> void:
	default_player_camera_reference.queue_free()

func _entered_room_collider(_body: Node2D) -> void:
	world_controller.entered_room(self)
func _exited_room_collider(_body: Node2D) -> void:
	world_controller.exited_room(self)

func change_camera_bounds(zoom : float = camera_zoom) -> void:
	player = $"../../../Player"
	player_camera = player.get_camera()
	camera_boundary_top_left = level_bounds.shape.get_rect().position
	camera_boundary_bottom_right = level_bounds.shape.get_rect().end
	if zoom:
		player_camera.change_zoom_to(camera_zoom)
	else:
		player_camera.change_zoom_to(0.36)
	bounds.top = camera_boundary_top_left.y + level_bounds.position.y + self.position.y
	bounds.bottom = camera_boundary_bottom_right.y + level_bounds.position.y + self.position.y
	bounds.left = camera_boundary_top_left.x + level_bounds.position.x + self.position.x
	bounds.right = camera_boundary_bottom_right.x + level_bounds.position.x + self.position.x
	player_camera.change_bounds_to(bounds)

func enter_room():
	change_camera_bounds()
	z_index = 1
func exit_room():
	z_index = 0

@icon("res://Assets/Editor Icons/Room Icon.png")
class_name Room
extends Node2D

@export var camera_zoom : float
@export var zoom_to_fit : bool
@export var interior_room : bool
@export var hidden_room : bool

@onready var room_transition_controller: Node = $"../.."
@onready var level_bounds: CollisionShape2D = $Area2D/LevelBounds
@onready var player: Player = $"../../../Player"
var camera_boundary_top_left
var camera_boundary_bottom_right
var room_visited : bool = false

var has_crittr : bool = false
var has_collectible : bool = false
var has_save_point : bool = false
var save_point_ref : SavePoint

@onready var region = get_parent()

#Camera Bounds defined by the Level Bounds collision shape in each room
var bounds : Dictionary = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0
}

var room_id : String
func _ready() -> void:
	EventController.connect("collectable_collected",collectable_collected)
	room_id = "%s(%s,%s)" % [name,global_position.x,global_position.y]
	if room_id in GameController.game_state.explored_rooms:
		room_visited = true
	
	for child in get_children():
		if child is Collectable:
			if child.id not in GameController.game_state.collected_ids:
				has_collectible = true
		if child is SavePoint:
			has_save_point = true
			save_point_ref = child

func collectable_collected(id, _value):
	has_collectible = false
	for child in get_children():
		if child is Collectable:
			if child.id != id:
				has_collectible = true

func get_respawn_point():
	for child in get_children():
		if child is RespawnPoint:
			return child.get_respawn_point()

func _entered_room_collider(_body: Node2D) -> void:
	room_transition_controller.transition_room(self)

func _process(_delta: float) -> void:
	if room_transition_controller.current_room == self:
		room_transition_controller.play_music(room_transition_controller.current_room.region.music)
		z_index = 2
	else:
		z_index = 0

func enter_room():
	change_camera_bounds()
	room_visited = true
	EventController.emit_signal("room_explored",room_id)
	room_transition_controller.play_music(room_transition_controller.current_room.region.music)

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
			
	bounds.top = camera_boundary_top_left.y + self.global_position.y
	bounds.bottom = camera_boundary_bottom_right.y + self.global_position.y
	bounds.left = camera_boundary_top_left.x + self.global_position.x
	bounds.right = camera_boundary_bottom_right.x + self.global_position.x
	
	player.camera.change_bounds_to(bounds)
	if snap_camera:
		player.camera.position_smoothing_enabled = true

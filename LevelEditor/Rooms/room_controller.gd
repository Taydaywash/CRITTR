extends Room
@onready var default_player_camera_reference: Camera2D = $defaultPlayerCameraReference
@onready var room_controller: Node = $".."

func _ready() -> void:
	default_player_camera_reference.queue_free()

func _entered_room_collider(_body: Node2D) -> void:
	room_controller.entered_room(self)
func _exited_room_collider(_body: Node2D) -> void:
	room_controller.exited_room(self)

func enter_room():
	change_camera_bounds()
	z_index = 1
func exit_room():
	z_index = 0

extends Camera2D

@export var camera_zoom : float

func _ready() -> void:
	zoom = Vector2(camera_zoom,camera_zoom)

func change_bounds_to(bounds : Dictionary):
	limit_top = bounds.top
	limit_bottom = bounds.bottom
	limit_left = bounds.left
	limit_right = bounds.right
	
func change_zoom_to():
	pass

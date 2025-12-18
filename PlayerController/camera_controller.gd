extends Camera2D

@export var default_zoom : float

func _ready() -> void:
	change_zoom_to(default_zoom)

func change_bounds_to(bounds : Dictionary):
	limit_top = bounds.top
	limit_bottom = bounds.bottom
	limit_left = bounds.left
	limit_right = bounds.right
	
func change_zoom_to(zoom_in):
	zoom = Vector2(zoom_in,zoom_in)

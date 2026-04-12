extends Camera2D

@export var default_zoom : float
@export var max_shake: float = 10.0
@export var shake_fade: float = 10.0

var limit_smoothed_timer
var shake_strength: float = 0.0

@onready var shake_timer: Timer = $ShakeTimer

func _ready() -> void:
	change_zoom_to(default_zoom)

func _process(delta: float) -> void:
	if not shake_timer.is_stopped():
		offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	elif shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	else:
		offset = Vector2.ZERO

func trigger_shake(shaker_duration: float) -> void:
	shake_strength = max_shake
	shake_timer.stop()
	shake_timer.wait_time = shaker_duration
	shake_timer.start()

func _on_shake_timer_timeout():
	pass 

func change_bounds_to(bounds : Dictionary):
	position_smoothing_enabled = false
	limit_top = bounds.top
	limit_bottom = bounds.bottom
	limit_left = bounds.left
	limit_right = bounds.right
	reset_smoothing()
	position_smoothing_enabled = true
	
func change_zoom_to(zoom_in):
	zoom = Vector2(zoom_in,zoom_in)

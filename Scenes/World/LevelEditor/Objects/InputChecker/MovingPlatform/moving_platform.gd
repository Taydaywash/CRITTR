
extends Path2D
@onready var timer = $Timer
@onready var path = $PathFollow2D
var moving_forward = true
@export var duration: float = 5
@export var timer_offset: float = 0
@export var stay: bool = false

func _ready():
	get_parent().connect("sequence_matched", start_timer)
	timer.wait_time = duration
	path.progress_ratio = 0.0

func start_timer() -> void:
	timer.start()
	var tween = create_tween()
	tween.tween_property(path, "progress_ratio", 1.0, 1.0 + timer_offset).set_trans(Tween.TRANS_SINE)

func _on_timer_timeout() -> void:
	if (!stay): 
		var tween = create_tween()
		tween.tween_property(path, "progress_ratio", 0.0, 1.0 + timer_offset).set_trans(Tween.TRANS_SINE)

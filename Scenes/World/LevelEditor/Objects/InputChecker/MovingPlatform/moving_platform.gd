extends Path2D
@onready var timer = $Timer
@onready var path = $PathFollow2D
var moving_forward = true
var tween: Tween
@export var duration: float = 5
@export var timer_offset: float = 0
@export var stay: bool = false

func _ready():
	get_parent().connect("sequence_matched", start_timer)
	EventController.connect("player_respawn", player_death)
	timer.wait_time = duration
	path.progress_ratio = 0.0

func start_timer() -> void:
	timer.start()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(path, "progress_ratio", 1.0, 1.0 + timer_offset).set_trans(Tween.TRANS_SINE)

func _on_timer_timeout() -> void:
	if (!stay): 
		tween = create_tween()
		tween.tween_property(path, "progress_ratio", 0.0, 1.0 + timer_offset).set_trans(Tween.TRANS_SINE)

func player_death() -> void:
	if tween:
		tween.kill()
	path.progress_ratio = 0
	path.progress = 0

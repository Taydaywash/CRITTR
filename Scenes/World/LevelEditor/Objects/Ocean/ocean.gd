@tool
extends CanvasGroup

@export var size: Vector2 = Vector2(640, 640):
	set(v):
		size = v
		update_shape()

@export var breath_duration: float = 8.0

var player_in_water: Node2D = null
var in_air_pocket: bool = false

func _ready() -> void:
	update_shape()

	if not Engine.is_editor_hint():
		$BreathTimer.wait_time = breath_duration
		$BreathTimer.one_shot  = true

func update_shape() -> void:
	var half := size / 2.0
	var verts := PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2( half.x, -half.y),
		Vector2( half.x,  half.y),
		Vector2(-half.x,  half.y),
	])
	if has_node("WaterShape"):
		$WaterShape.polygon = verts
	if has_node("Area2D/CollisionShape2D"):
		var shape := RectangleShape2D.new()
		shape.size = size
		$Area2D/CollisionShape2D.shape = shape

func _on_body_entered(body: Node2D) -> void:
	player_in_water = body
	start_breath_timer()

func _on_body_exited(_body: Node2D) -> void:
	player_in_water = null
	$BreathTimer.stop()

func _on_breath_timeout() -> void:
	if player_in_water:
		EventController.emit_signal("player_death")
		$BreathTimer.start()

func start_breath_timer() -> void:
	$BreathTimer.wait_time = breath_duration
	$BreathTimer.start()

func enter_air_pocket() -> void:
	in_air_pocket = true
	$BreathTimer.stop()

func exit_air_pocket() -> void:
	in_air_pocket = false
	if player_in_water:
		start_breath_timer()

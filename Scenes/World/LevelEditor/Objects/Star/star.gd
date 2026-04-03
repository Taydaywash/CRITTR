extends Sprite2D

var player_inside: bool = false
var jump_available: bool = false
@onready var room_reference: Room = $".."

func _ready() -> void:
	room_reference.connect("room_is_active",room_is_active)
	room_reference.connect("room_is_inactive",room_is_inactive)

func room_is_active() -> void:
	add_to_group("jump_zone")
func room_is_inactive() -> void:
	remove_from_group("jump_zone")

func _on_area_2d_body_entered(_body):
	player_inside = true
	jump_available = true

func _on_area_2d_body_exited(_body):
	player_inside = false

func _on_timer_timeout():
	self_modulate.a = 1
	$Area2D.set_deferred("monitoring", true)
	$Area2D.set_deferred("monitorable", true)

func deactivate():
	jump_available = false
	self_modulate.a = 0.5
	$Timer.start()
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)

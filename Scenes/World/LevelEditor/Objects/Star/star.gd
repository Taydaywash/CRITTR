extends AnimatedSprite2D

var player_inside: bool = false
var jump_available: bool = false
@onready var room_reference: Room = $".."
@onready var point_light_2d: PointLight2D = $PointLight2D

func _ready() -> void:
	room_reference.connect("room_is_active",room_is_active)
	room_reference.connect("room_is_inactive",room_is_inactive)
	animation_loop()
func animation_loop():
	play("flicker")
	await get_tree().create_timer(randf_range(0.1,1)).timeout
	animation_loop()

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
	point_light_2d.visible = true
	self_modulate.a = 1
	$Area2D.set_deferred("monitoring", true)
	$Area2D.set_deferred("monitorable", true)

func deactivate():
	jump_available = false
	point_light_2d.visible = false
	self_modulate.a = 0.5
	$Timer.start()
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)

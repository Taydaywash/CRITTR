extends Sprite2D

var player_inside: bool = false
var jump_available: bool = false

func _ready() -> void:
	pass
	
func _on_area_2d_body_entered(_body):
	player_inside = true
	jump_available = true

func _on_area_2d_body_exited(_body):
	player_inside = false
	if not jump_available:
		self_modulate.a = 0.5
		$Timer.start()
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)
	print("Player Exit")

	

func _on_timer_timeout():
	self_modulate.a = 1
	$Area2D.set_deferred("monitoring", true)
	$Area2D.set_deferred("monitorable", true)

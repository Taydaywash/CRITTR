extends "res://PlayerController/player_controller.gd"

func _process(_delta: float) -> void:
	player_sprite.modulate = Color(1,1,1)
	if diving:
		if not has_bonked:
			player_sprite.modulate = Color(0,0,0)
		elif has_bonked:
			player_sprite.modulate = Color(0.5,0.5,0.5)
	elif not grounded:
		if velocity.y < 0:
			player_sprite.modulate = Color(0,1,0)
		elif velocity.y > 0:
			player_sprite.modulate = Color(1,0,0)
	

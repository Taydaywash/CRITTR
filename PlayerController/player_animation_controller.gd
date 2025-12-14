extends "res://PlayerController/player_controller.gd"

func _process(_delta: float) -> void:
	player_sprite.modulate = Color(1,1,1)
	if velocity.x < 0:
		player_sprite.flip_h = true
	else:
		player_sprite.flip_h = false
	if diving:
		if velocity.x == 0:
			player_sprite.modulate = Color(0.2,0.2,0.2)
		elif not has_bonked:
			player_sprite.modulate = Color(0,0,0)
		elif has_bonked:
			player_sprite.modulate = Color(0.5,0.5,0.5)
		
	elif not grounded:
		if velocity.y < 0:
			player_sprite.modulate = Color(0,1,0)
		elif velocity.y > 0:
			player_sprite.modulate = Color(1,0,0)
	elif abs(velocity.x) > 0:
		player_sprite.modulate = Color(0,0.5,1)

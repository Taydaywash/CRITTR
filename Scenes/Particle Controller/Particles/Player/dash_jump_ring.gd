extends Particle

@export var player_min_velocity : int

func _process(_delta: float) -> void:
	if player:
		if player.velocity.y == 0 or  player.velocity.x == 0 or player.velocity.length() < player_min_velocity:
			emitting = false
		angle_min = rad_to_deg(get_angle_to(global_position + player.velocity.normalized()))
		angle_max = rad_to_deg(get_angle_to(global_position + player.velocity.normalized()))

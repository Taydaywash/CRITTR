extends Particle

@export var player_min_velocity : int
var stop_tracking : bool = false

func _process(_delta: float) -> void:
	if stop_tracking:
		return
	if player:
		if player.velocity.y == 0 or  player.velocity.x == 0 or player.velocity.length() < player_min_velocity:
			stop_tracking = true
			emitting = false
			return
		angle_min = rad_to_deg(get_angle_to(global_position + player.velocity.normalized()))
		angle_max = rad_to_deg(get_angle_to(global_position + player.velocity.normalized()))

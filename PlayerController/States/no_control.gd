extends State

var max_falling_speed
var gravity

func process_frame(delta) -> State:
	max_falling_speed = player.max_falling_speed
	gravity = player.normal_gravity
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	player.move_and_slide()
	return null

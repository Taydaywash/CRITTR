extends State

var max_falling_speed
var gravity

func activate(_last_state : State) -> void:
	max_falling_speed = parent.max_falling_speed
	gravity = parent.normal_gravity

func process_frame(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	parent.move_and_slide()
	return null

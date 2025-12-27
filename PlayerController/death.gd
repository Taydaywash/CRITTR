extends State

var max_falling_speed
var gravity

func activate(_last_state : State) -> void:
	super(_last_state)
	max_falling_speed = parent.max_falling_speed
	gravity = parent.normal_gravity

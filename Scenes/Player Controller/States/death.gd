extends State

var max_falling_speed
var gravity

func activate(_last_state : State) -> void:
	super(_last_state)
	max_falling_speed = player.max_falling_speed
	gravity = player.normal_gravity

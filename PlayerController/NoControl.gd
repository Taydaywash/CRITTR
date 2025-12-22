extends State

func activate(_last_state : State) -> void:
	parent.velocity = Vector2(0,0)
func deactivate(_next_state : State) -> void:
	parent.velocity = Vector2(0,0)

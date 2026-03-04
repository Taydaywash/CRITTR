extends State

func process_frame(_delta) -> State:
	player.move_and_slide()
	return null

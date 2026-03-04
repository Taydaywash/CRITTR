extends State

var done_respawning = false

func activate(last_state : State) -> void:
	done_respawning = false
	super(last_state)
	await sprite.animation_finished
	done_respawning = true
func process_frame(_delta) -> State:
	if done_respawning:
		return idle_state
	return

extends State

#States that Bonked can transition to:
@export_category("States")
@export var idle_state : State
@export var jumping_state : State
@export_category("Parameters")
@export var dive_bonk_horizontal_velocity : int
@export var dive_bonk_vertical_velocity : int
@export_category("Jump Input Buffer")
@export var jump_input_buffer : Timer
@export var jump_input_buffer_patience : float
var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	jump_input_buffer.wait_time = jump_input_buffer_patience
	
	parent.velocity.x = -dive_bonk_horizontal_velocity * -parent.get_wall_normal().x
	parent.velocity.y = -dive_bonk_vertical_velocity
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed

func process_input(event) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		jump_input_buffer.stop()
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return jumping_state
		else:
			return idle_state
	return null

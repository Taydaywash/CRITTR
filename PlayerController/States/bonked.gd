extends State

#States that Idle can transition to:
@export var idle_state : State
@export var dive_bonk_horizontal_velocity : int
@export var dive_bonk_vertical_velocity : int

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	parent.velocity.x = -dive_bonk_horizontal_velocity * -parent.get_wall_normal().x
	parent.velocity.y = -dive_bonk_vertical_velocity
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed

func process_physics(_delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		return idle_state
	return null

extends State

#States that Idle can transition to:
@export var walking_state : State
@export var falling_state : State
@export var jumping_state : State
@export var diving_state : State

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	parent.velocity.x = 0
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("dive"):
		return diving_state
	if Input.get_axis("move_left","move_right") != 0:
		return walking_state
	if Input.is_action_just_pressed("jump") and parent.is_on_floor():
		return jumping_state
	return null

func process_physics(_delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return falling_state
	return null

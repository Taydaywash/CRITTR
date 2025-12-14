extends State

#States that Dashing can transition to:
@export var walking_state : State
@export var jumping_state : State
@export var falling_state : State
@export var diving_state : State
@export var wall_cling_state : State

@export var dive_horizontal_additive_velocity : int
@export var dive_horizontal_default_velocity : int
@export var dive_vertical_velocity : int
@export var jump_input_buffer_patience : float
@export var idle_dive_sprite : Color

var jump_input_buffer : Timer
var dash_timer_time : Timer
var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("jump"):
		jump_input_buffer.start()
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return jumping_state
		else:
			return walking_state
	return null

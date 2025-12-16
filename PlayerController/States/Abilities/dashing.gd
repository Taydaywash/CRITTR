extends State

#States that Idle can transition to:
@export_category("States")
@export var jumping_state : State
@export var walking_state : State
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var ascending_state : State
@export_category("Parameters")
@export var dashing_speed : int
@export var dash_duration : float #seconds
@export var dash_vertical_end_velocity_multiplier : float
@export var dash_horizontal_end_velocity_multiplier : float
@export var super_jump_velocity : int
@export var jump_input_buffer_patience : float
@export_category("Corner Nudging Raycasts")
@export var nudge_right_range_left: RayCast2D
@export var nudge_right_range_right: RayCast2D
@export var nudge_left_range_right: RayCast2D
@export var nudge_left_range_left: RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var dash_timer : Timer
var jump_input_buffer: Timer

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	#Dash timer setup:
	dash_timer = Timer.new()
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	add_child(dash_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	
	parent.velocity = Vector2(0,0)
	if direction == "up":
		dash_timer.start()
		parent.velocity.y = -dashing_speed
	elif direction == "down":
		if parent.is_on_floor():
			parent.velocity.y = -super_jump_velocity
		else:
			dash_timer.start()
			parent.velocity.y = dashing_speed
	elif direction == "left":
		dash_timer.start()
		parent.velocity.x = -dashing_speed
	elif direction == "right":
		dash_timer.start()
		parent.velocity.x = dashing_speed

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("jump"):
		jump_input_buffer.start()
	if Input.is_action_just_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	parent.move_and_slide()
	if (parent.is_on_wall() and parent.velocity.y == 0) or parent.is_on_ceiling():
		return falling_state
	if (parent.is_on_floor() and dash_timer.time_left == 0):
		if jump_input_buffer.time_left > 0:
			return jumping_state
		if abs(parent.velocity.x) > 0:
			return walking_state
		else:
			return idle_state
	if (!parent.is_on_floor() and dash_timer.time_left == 0):
		return ascending_state
	return null

func deactivate(_new_state) -> void:
	parent.velocity.x = parent.velocity.x * dash_horizontal_end_velocity_multiplier 
	parent.velocity.y = parent.velocity.y * dash_vertical_end_velocity_multiplier 

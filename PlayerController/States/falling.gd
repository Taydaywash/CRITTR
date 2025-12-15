extends State

#States that Falling can transition to:
@export_category("States")
@export var idle_state : State
@export var walking_state : State
@export var diving_state : State
@export var wall_cling_state : State
@export var jumping_state : State
@export var wall_jumping_state : State
@export var ability_state : State
@export_category("Parameters")
@export var air_control : int
@export var air_acceleration_speed : int
@export var air_decceleration_speed : int

@export var jump_input_buffer_patience : float
@export var coyote_time_patience : float

var coyote_time : Timer
var jump_input_buffer : Timer
var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

@onready var right_ray: RayCast2D = $"../../WallJumpRayReference/RightRay"
@onready var left_ray: RayCast2D = $"../../WallJumpRayReference/LeftRay"

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	#Coyote time setup:
	coyote_time = Timer.new()
	coyote_time.wait_time = coyote_time_patience
	coyote_time.one_shot = true
	add_child(coyote_time)

func activate(last_state : State) -> void:
	super(last_state) #Call activate() as defined in state.gd and then also do:
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed
	if(last_state == $"../Walking"):
		coyote_time.start()

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("ability_up") or Input.is_action_just_pressed("ability_down") or Input.is_action_just_pressed("ability_left") or Input.is_action_just_pressed("ability_right"):
		return ability_state
	if Input.is_action_just_pressed("dive"):
		return diving_state
	if Input.is_action_just_pressed("jump"):
		if coyote_time.time_left > 0:
			return jumping_state
		else:
			jump_input_buffer.start()
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(parent.velocity.x) < air_control):
		parent.velocity.x += air_acceleration_speed * delta * horizontal_input
	if horizontal_input == 0 or (sign(horizontal_input) != sign(parent.velocity.x)):
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),air_decceleration_speed * delta).x
	parent.move_and_slide()
	
	
	if (left_ray.is_colliding() or right_ray.is_colliding()):
		if jump_input_buffer.time_left > 0:
			return wall_jumping_state
		elif parent.is_on_wall():
			return wall_cling_state
	if parent.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return jumping_state
		if parent.velocity.x == 0:
			return idle_state
		else:
			return walking_state
	return null

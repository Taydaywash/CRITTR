extends State

#States that Jumping can transition to:
@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var walking_state : State
@export var diving_state : State
@export var ability_state : State
@export_category("Parameters")
@export var air_control : int
@export var wall_jump_horizontal_velocity : int
@export var wall_jump_vertical_velocity : int
@export var jump_cancellation : int
@export var air_acceleration_speed : int
@export var air_decceleration_speed : int
@export var jump_input_buffer_patience : float
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

var jump_input_buffer : Timer

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)

func activate(last_state : State) -> void:
	super(last_state) #Call activate() as defined in state.gd and then also do:
	gravity = parent.normal_gravity
	parent.velocity.y = -wall_jump_vertical_velocity
	max_falling_speed = parent.max_falling_speed
	if right_ray.is_colliding():
		parent.velocity.x = -wall_jump_horizontal_velocity
	elif left_ray.is_colliding():
		parent.velocity.x = wall_jump_horizontal_velocity

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("ability_up") or Input.is_action_just_pressed("ability_down") or Input.is_action_just_pressed("ability_left") or Input.is_action_just_pressed("ability_right"):
		return ability_state
	if Input.is_action_just_pressed("jump"):
		jump_input_buffer.start()
	if Input.is_action_just_released("jump"):
		parent.velocity.y = parent.velocity.y / jump_cancellation
	if Input.is_action_just_pressed("dive"):
		return diving_state
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(parent.velocity.x) < air_control) or (sign(horizontal_input) != sign(parent.velocity.x)):
		parent.velocity.x += air_acceleration_speed * delta * horizontal_input
	if horizontal_input == 0:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),air_decceleration_speed * delta).x
	
	parent.move_and_slide()
	
	if parent.velocity.y > 0:
		return falling_state
	if parent.is_on_floor():
		if abs(parent.velocity.x) > 0:
			return walking_state
		else:
			return idle_state
	return null

extends State

#States that Wall cling can transition to:
@export_category("States")
@export var falling_state : State
@export var jumping_state : State
@export var walking_state : State
@export var wall_jumping_state : State
@export var ability_state : State
@export_category("Parameters")
@export var walk_speed : int
@export var acceleration_speed : int
@export var decceleration_speed : int
@export var wall_jump_horizontal_velocity : int
@export var wall_jump_vertical_velocity : int
@export var wall_cling_gravity : int
@export var max_wall_cling_fall_speed: int
@export_category("Jump Input Buffer")
@export var jump_input_buffer : Timer
@export var jump_input_buffer_patience : float
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D

var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	
	jump_input_buffer.wait_time = jump_input_buffer_patience
	
	max_falling_speed = parent.max_falling_speed

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("use_ability"):
		return ability_state
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_wall_cling_fall_speed:
		parent.velocity.y += wall_cling_gravity * delta
	else:
		parent.velocity.y = parent.velocity.move_toward(Vector2(0,max_wall_cling_fall_speed),decceleration_speed * delta).y
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(parent.velocity.x) < walk_speed) or (sign(horizontal_input) != sign(parent.velocity.x)):
		parent.velocity.x += acceleration_speed * delta * horizontal_input
	if horizontal_input == 0:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	parent.move_and_slide()
	
	if jump_input_buffer.time_left > 0:
		return wall_jumping_state
	if !parent.is_on_wall():
		return falling_state
	if parent.is_on_floor():
		return walking_state
	return null

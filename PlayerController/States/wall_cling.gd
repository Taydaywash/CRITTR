extends State

#States that Idle can transition to:
@export var falling_state : State
@export var jumping_state : State
@export var walking_state : State

var max_falling_speed : int
var horizontal_input : int = 0

@export var walk_speed : int
@export var acceleration_speed : int
@export var decceleration_speed : int
@export var wall_jump_horizontal_velocity : int
@export var wall_jump_vertical_velocity : int
@export var wall_cling_gravity : int

@onready var right_ray: RayCast2D = $"../../WallJumpRayReference/RightRay"
@onready var left_ray: RayCast2D = $"../../WallJumpRayReference/LeftRay"

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	parent.velocity.x = 0
	max_falling_speed = parent.max_falling_speed

func process_input(_event : InputEvent) -> State:
	if Input.get_axis("move_left","move_right") != 0:
		if !parent.is_on_wall():
			return falling_state

	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += wall_cling_gravity
		
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(parent.velocity.x) < walk_speed) or (sign(horizontal_input) != sign(parent.velocity.x)):
		parent.velocity.x += acceleration_speed * delta * horizontal_input
	if horizontal_input == 0:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	parent.move_and_slide()
	if Input.is_action_just_pressed("jump"):
		if parent.is_on_wall():
			parent.velocity.x = wall_jump_horizontal_velocity * parent.get_wall_normal().x
		return jumping_state
	if parent.is_on_floor():
		return walking_state
	return null

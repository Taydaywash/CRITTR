extends State

#States that Wall cling can transition to:
@export var falling_state : State
@export var jumping_state : State
@export var walking_state : State
@export var wall_jumping_state : State
@export var ability_state : State

var max_falling_speed : int
var horizontal_input : int = 0

@export var walk_speed : int
@export var acceleration_speed : int
@export var decceleration_speed : int
@export var wall_jump_horizontal_velocity : int
@export var wall_jump_vertical_velocity : int
@export var wall_cling_gravity : int
@export var max_wall_cling_fall_speed: int

@onready var right_ray: RayCast2D = $"../../WallJumpRayReference/RightRay"
@onready var left_ray: RayCast2D = $"../../WallJumpRayReference/LeftRay"

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	max_falling_speed = parent.max_falling_speed

func process_input(_event : InputEvent) -> State:
	var used_ability = Input.is_action_just_pressed("ability_up") or Input.is_action_just_pressed("ability_down") or Input.is_action_just_pressed("ability_left") or Input.is_action_just_pressed("ability_right")
	if used_ability:
		return ability_state
	if Input.is_action_just_pressed("jump"):
		return wall_jumping_state
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
	
	if !parent.is_on_wall():
		return falling_state
	if parent.is_on_floor():
		return walking_state
	return null

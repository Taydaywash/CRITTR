extends State

#States that Jumping can transition to:
@export_category("States")
@export var falling_state : State
@export var diving_state : State
@export var wall_jumping_state : State
@export var idle_state : State
@export var walking_state : State
@export var ability_state : State
@export_category("Parameters")
@export var air_control : int
@export var air_acceleration_speed : int
@export var air_decceleration_speed : int

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

@onready var right_ray: RayCast2D = $"../../WallJumpRayReference/RightRay"
@onready var left_ray: RayCast2D = $"../../WallJumpRayReference/LeftRay"

@onready var nudge_right_range_left: RayCast2D = $"../../CornerNudging/NudgeRightRangeLeft"
@onready var nudge_right_range_right: RayCast2D = $"../../CornerNudging/NudgeRightRangeRight"
@onready var nudge_left_range_right: RayCast2D = $"../../CornerNudging/NudgeLeftRangeRight"
@onready var nudge_left_range_left: RayCast2D = $"../../CornerNudging/NudgeLeftRangeLeft"

@export var jump_input_buffer_patience : float

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
	max_falling_speed = parent.max_falling_speed

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("ability_up") or Input.is_action_just_pressed("ability_down") or Input.is_action_just_pressed("ability_left") or Input.is_action_just_pressed("ability_right"):
		return ability_state
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
	elif parent.velocity.y < 0:
		if nudge_right_range_left.is_colliding() and !nudge_right_range_right.is_colliding():
			parent.position.x += 14
		if nudge_left_range_right.is_colliding() and !nudge_left_range_left.is_colliding():
			parent.position.x -= 14
	if parent.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return self
		else:
			if abs(parent.velocity.x) > 0:
				return walking_state
			else:
				return idle_state
	if (left_ray.is_colliding()  or right_ray.is_colliding()) and jump_input_buffer.time_left > 0:
		return wall_jumping_state
	return null

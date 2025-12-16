extends State

#States that Walking can transition to:
@export_category("States")
@export var idle_state : State
@export var crouching_state : State
@export var falling_state : State
@export var jumping_state : State
@export var diving_state : State
@export var ability_state : State
@export_category("Parameters")
@export var walk_speed : int
@export var acceleration_speed : int
@export var decceleration_speed : int
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var coyote_time : Timer

func activate(last_state : State) -> void:
	super(last_state) #Call activate() as defined in state.gd and then also do:
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("ability_up") or Input.is_action_just_pressed("ability_down") or Input.is_action_just_pressed("ability_left") or Input.is_action_just_pressed("ability_right"):
		return ability_state
	if Input.is_action_just_pressed("move_down"):
		return crouching_state
	if Input.is_action_just_pressed("dive"):
		return diving_state
	if Input.is_action_just_pressed("jump") and parent.is_on_floor():
		return jumping_state
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(parent.velocity.x) < walk_speed) or (sign(horizontal_input) != sign(parent.velocity.x)):
		parent.velocity.x += acceleration_speed * delta * horizontal_input
	else:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	if horizontal_input == 0:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	parent.move_and_slide()
	if !parent.is_on_floor():
		return falling_state
	if parent.velocity.x == 0 and horizontal_input == 0:
		return idle_state
	if parent.is_on_wall() and horizontal_input != 0:
		if (right_ray.is_colliding() or left_ray.is_colliding()):
			return idle_state
		parent.position.x += 10 * horizontal_input
		return crouching_state
	return null

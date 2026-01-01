extends State

#States that Idle can transition to:
@export_category("States")
@export var walking_state : State
@export var crouching_state : State
@export var falling_state : State
@export var jumping_state : State
@export var diving_state : State
@export var ability_state : State
@export var looking_up_state : State
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	player.velocity.x = 0
	gravity = player.normal_gravity
	max_falling_speed = player.max_falling_speed

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("use_ability"):
		return ability_state
	if event.is_action_pressed("move_down"):
		return crouching_state
	if event.is_action_pressed("dive"):
		return diving_state
	if event.is_action_pressed("jump") and player.is_on_floor():
		return jumping_state
	if event.is_action_pressed("move_up"):
		return looking_up_state
	return null

func process_physics(delta) -> State:
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	player.velocity.x += horizontal_input * 100
	player.move_and_slide()
	
	if player.is_on_wall() and horizontal_input != 0:
		if (right_ray.is_colliding() or left_ray.is_colliding()):
			return self
		player.position.x += 10 * horizontal_input
		return crouching_state
	if horizontal_input != 0:
		return walking_state
	if !player.is_on_floor():
		return falling_state
	return null

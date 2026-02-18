extends State

#States that Idle can transition to:
@export_category("States")
@export var walking_state : State
@export var crouching_state : State
@export var falling_state : State
@export var jumping_state : State
@export var diving_state : State
@export var ability_state : State
@export var idle_state : State
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D
@export_category("References")
@export var camera_reference : Camera2D
@export_category("Parameters")
@export var camera_offset : int
@export var look_up_delay : float

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var look_up_delay_timer : Timer

func _ready() -> void:
	look_up_delay_timer = Timer.new()
	look_up_delay_timer.wait_time = look_up_delay
	look_up_delay_timer.one_shot = true
	add_child(look_up_delay_timer)

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	look_up_delay_timer.start()
	await look_up_delay_timer.timeout
	camera_reference.position.y = -camera_offset
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
	if event.is_action_released("move_up"):
		return idle_state
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

func deactivate(_next_state : State) -> void:
	super(_next_state)
	look_up_delay_timer.stop()
	camera_reference.position.y = 0

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
@export var jump_input_buffer_patience : float
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D
@export_category("Corner Nudging Raycasts")
@export var nudge_right_range_left: RayCast2D
@export var nudge_right_range_right: RayCast2D
@export var nudge_left_range_right: RayCast2D
@export var nudge_left_range_left: RayCast2D

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
	gravity = player.normal_gravity
	max_falling_speed = player.max_falling_speed

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("use_ability"):
		return ability_state
	if event.is_action_pressed("dive"):
		return diving_state
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		jump_input_buffer.stop()
	return null

func process_physics(delta) -> State:
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(player.velocity.x) < air_control) or (sign(horizontal_input) != sign(player.velocity.x)):
		player.velocity.x += air_acceleration_speed * delta * horizontal_input
	if horizontal_input == 0:
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),air_decceleration_speed * delta).x
	player.move_and_slide()
	
	if player.velocity.y > 0:
		return falling_state
	elif player.velocity.y < 0:
		if nudge_right_range_left.is_colliding() and !nudge_right_range_right.is_colliding():
			player.position.x += 14
		if nudge_left_range_right.is_colliding() and !nudge_left_range_left.is_colliding():
			player.position.x -= 14
	if (left_ray.is_colliding() or right_ray.is_colliding()) and jump_input_buffer.time_left > 0:
		return wall_jumping_state
	if player.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return self
		else:
			if abs(player.velocity.x) > 0:
				return walking_state
			else:
				return idle_state
	if (left_ray.is_colliding()  or right_ray.is_colliding()) and jump_input_buffer.time_left > 0:
		return wall_jumping_state
	return null

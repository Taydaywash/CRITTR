extends State

#States that Jumping can transition to:
@export_category("Parameters")
@export var move_speed : int
@export var wall_jump_horizontal_velocity : int
@export var wall_jump_vertical_velocity : int
@export var wall_dash_jump_vertical_velocity : int
@export var wall_dash_jump_horizontal_velocity : int
@export var jump_cancellation : int
@export var acceleration_speed : int
@export var decceleration_speed : int
@export var high_velocity_decceleration_speed : int
@export_category("Jump Input Buffer")
@export var jump_input_buffer : Timer
@export var jump_input_buffer_patience : float
@export_category("Wall Jumping Raycasts")
@export var right_ray: RayCast2D
@export var left_ray: RayCast2D
@export var high_right_ray: RayCast2D
@export var high_left_ray: RayCast2D
@export var low_right_ray: RayCast2D
@export var low_left_ray: RayCast2D
@export_category("Corner Nudging Raycasts")
@export var nudge_right_range_left: RayCast2D
@export var nudge_right_range_right: RayCast2D
@export var nudge_left_range_left: RayCast2D
@export var nudge_left_range_right: RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	var dash_jumping = false
	super(last_state) #Call activate() as defined in state.gd and then also do:
	
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true

	jump_input_buffer.stop()
	gravity = player.normal_gravity
	if -wall_jump_vertical_velocity < player.velocity.y:
		player.velocity.y = -wall_jump_vertical_velocity
	if last_state == dashing_state:
		player.velocity.y = -wall_dash_jump_vertical_velocity
		dash_jumping = true
	max_falling_speed = player.max_falling_speed
	if right_ray.is_colliding() or high_right_ray.is_colliding() or low_right_ray.is_colliding():
		if dash_jumping:
			player.velocity.x = -wall_dash_jump_horizontal_velocity
			return
		player.velocity.x = -wall_jump_horizontal_velocity
	elif left_ray.is_colliding() or low_left_ray.is_colliding() or high_left_ray.is_colliding():
		if dash_jumping:
			player.velocity.x = wall_dash_jump_horizontal_velocity
			return
		player.velocity.x = wall_jump_horizontal_velocity


func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("use_ability"):
		return ability_state
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		player.velocity.y = player.velocity.y / jump_cancellation
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(delta) -> State:
	nudge_right_range_left.target_position.y = player.velocity.y / 15
	nudge_right_range_right.target_position.y = player.velocity.y / 15
	nudge_left_range_right.target_position.y = player.velocity.y / 15
	nudge_left_range_left.target_position.y = player.velocity.y / 15
	
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if sign(horizontal_input) != sign(player.velocity.x):
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	elif (abs(player.velocity.x) <= move_speed) and horizontal_input:
		player.velocity.x = player.velocity.move_toward(Vector2(move_speed * horizontal_input,player.velocity.y)
																, acceleration_speed * delta).x
	elif sign(horizontal_input) == sign(player.velocity.x):
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),high_velocity_decceleration_speed * delta).x
	
	player.move_and_slide()
	if nudge_right_range_left.is_colliding() and not nudge_right_range_right.is_colliding() and not player.velocity.x < 0:
		player.position.x += nudge_right_range_right.position.x - nudge_right_range_left.position.x
	if nudge_left_range_right.is_colliding() and not nudge_left_range_left.is_colliding() and not player.velocity.x > 0:
		player.position.x -= nudge_left_range_right.position.x - nudge_left_range_left.position.x
	if (left_ray.is_colliding() or right_ray.is_colliding()):
		if jump_input_buffer.time_left > 0:
			return self
	if player.velocity.y > 0:
		return falling_state
	if player.is_on_floor():
		if abs(player.velocity.x) > 0:
			return walking_state
		else:
			return idle_state
	return null

func deactivate(next_state : State) -> void:
	super(next_state)
	nudge_right_range_left.target_position.y = -50
	nudge_right_range_right.target_position.y = -50
	nudge_left_range_right.target_position.y = -50
	nudge_left_range_left.target_position.y = -50

extends State

@export var icon : CompressedTexture2D

#States that Idle can transition to:
@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export var ascending_state : State

@export_category("Parameters")
@export var horizontal_end_speed_multiplier : float
@export var vertical_end_speed_multiplier : float
@export var jump_buffer_patience : float
@export var jump_velocity : float
@export var vertical_jump_velocity : float

@export_category("References")
@export var grapple_ray: RayCast2D
@export var line: Line2D
@export var jump_input_buffer : Timer

var direction : String
var grapple_current_length: float
var global_point: Vector2

func _ready() -> void:
	pass

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	jump_input_buffer.wait_time = jump_buffer_patience
	global_point = grapple_ray.get_collision_point()

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("dive"):
		return diving_state
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		jump_input_buffer.stop()
	return null

func process_physics(_delta) -> State:
	grapple_ray.target_position = grapple_ray.to_local(grapple_ray.get_collision_point())
	line.set_point_position(1, grapple_ray.to_local(grapple_ray.get_collision_point()))
	player.move_and_slide()
	
	if direction == "up" and player.global_position.y < global_point.y:
		if jump_input_buffer.time_left > 0:
			player.velocity.y = -vertical_jump_velocity
		return ascending_state
	elif direction == "down" and player.global_position.y > global_point.y:
		if jump_input_buffer.time_left > 0:
			player.velocity.y = -jump_velocity
		return ascending_state
	elif direction == "right" and player.global_position.x > global_point.x:
		if jump_input_buffer.time_left > 0:
			player.velocity.y = -jump_velocity
		return ascending_state
	elif direction == "left" and player.global_position.x < global_point.x:
		if jump_input_buffer.time_left > 0:
			player.velocity.y = -jump_velocity
		return ascending_state
	
	if player.get_slide_collision_count() > 0:
		if player.is_on_floor_only() and (direction == "right" or direction == "left"):
			return null
		return falling_state

	return null

func deactivate(_next_state) -> void:
	super(_next_state)
	player.velocity.x = player.velocity.x * horizontal_end_speed_multiplier
	grapple_ray.target_position = Vector2.ZERO
	line.clear_points()

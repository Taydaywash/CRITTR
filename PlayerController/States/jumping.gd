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
@export var jump_velocity : int
@export var jump_cancellation : int
@export var air_acceleration_speed : int
@export var air_decceleration_speed : int
@export var jump_input_buffer_patience : float
@export_category("Animations")
@export var y_sprite_stretch_multiplier : float
@export var x_sprite_stretch_multiplier : float
@export var sprite_reset_speed : float
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
	jump_input_buffer.stop()
	gravity = parent.normal_gravity
	parent.velocity.y = -jump_velocity
	max_falling_speed = parent.max_falling_speed
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	sprite.scale.y = y_sprite_stretch_multiplier
	sprite.scale.x = x_sprite_stretch_multiplier

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("use_ability"):
		return ability_state
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		parent.velocity.y = parent.velocity.y / jump_cancellation
	if event.is_action_pressed("dive"):
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
			parent.position.x += 15
		if nudge_left_range_right.is_colliding() and !nudge_left_range_left.is_colliding():
			parent.position.x -= 15
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

func process_frame(delta) -> State:
	sprite.scale.y = lerp(sprite.scale.y,1.0,sprite_reset_speed * delta)
	sprite.scale.x = lerp(sprite.scale.x,1.0,sprite_reset_speed * delta)
	return null

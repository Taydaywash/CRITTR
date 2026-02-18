extends State

#States that Diving can transition to:
@export_category("States")
@export var walking_state : State
@export var bonked_state : State
@export var jumping_state : State
@export var idle_state : State
@export var diving_falling_state : State
@export_category("Parameters")
@export var dive_horizontal_additive_velocity : int
@export var dive_horizontal_default_velocity : int
@export var dive_vertical_velocity : int
@export var idle_dive_sprite : Color
@export var max_diving_speed : int
@export_category("Jump Input Buffer")
@export var jump_input_buffer : Timer
@export var jump_input_buffer_patience : float
@export_category("Animations")
@export var y_initial_sprite_stretch_multiplier : float
@export var x_initial_sprite_stretch_multiplier : float
@export var sprite_reset_speed : float
@export var y_final_sprite_stretch_multiplier : float
@export var x_final_sprite_stretch_multiplier : float

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	jump_input_buffer.wait_time = jump_input_buffer_patience
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if horizontal_input == 0:
		horizontal_input = -(2 * int(sprite.flip_h) - 1)
	if last_state == idle_state:
		horizontal_input = 0
	if abs(player.velocity.x) > dive_horizontal_default_velocity:
		if abs(player.velocity.x) < max_diving_speed:
			player.velocity.x += dive_horizontal_additive_velocity * horizontal_input
	else:
		player.velocity.x = dive_horizontal_default_velocity * horizontal_input
	player.velocity.y = -dive_vertical_velocity
	gravity = player.normal_gravity
	max_falling_speed = player.max_falling_speed
	
	sprite.scale = Vector2(abs(x_initial_sprite_stretch_multiplier * player.velocity.normalized().x),y_initial_sprite_stretch_multiplier * -player.velocity.normalized().y)
	sprite.rotation = -player.velocity.normalized().x

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		jump_input_buffer.stop()
	return null

func process_physics(delta) -> State:
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	player.move_and_slide()
	
	if player.is_on_wall():
		return bonked_state
	if player.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return jumping_state
		else:
			return walking_state
	if player.velocity.y > 0:
		return diving_falling_state
	return null

func process_frame(_delta) -> State:
	sprite.scale = lerp(sprite.scale, Vector2(1,1), sprite_reset_speed)
	sprite.rotation = lerp(sprite.rotation, 0.45 * player.velocity.normalized().x, sprite_reset_speed)
	return null

extends State

#States that Diving can transition to:
@export_category("States")
@export var walking_state : State
@export var bonked_state : State
@export var jumping_state : State
@export var idle_state : State
@export_category("Jump Input Buffer")
@export var jump_input_buffer : Timer
@export var jump_input_buffer_patience : float
@export_category("Animations")
@export var sprite_reset_speed : float
@export var y_final_sprite_stretch_multiplier : float
@export var x_final_sprite_stretch_multiplier : float

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(_last_state : State) -> void:
	super(_last_state)
	jump_input_buffer.wait_time = jump_input_buffer_patience
	
	gravity = player.normal_gravity
	max_falling_speed = player.max_falling_speed

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
	return null

func process_frame(_delta) -> State:
	sprite.scale = lerp(sprite.scale, Vector2(1,1), sprite_reset_speed)
	sprite.rotation = lerp(sprite.rotation, 0.45 * player.velocity.normalized().x, sprite_reset_speed)
	return null

extends State

#States that Diving can transition to:
@export_category("States")
@export var walking_state : State
@export var bonked_state : State
@export var jumping_state : State
@export_category("Parameters")
@export var dive_horizontal_additive_velocity : int
@export var dive_horizontal_default_velocity : int
@export var dive_vertical_velocity : int
@export var jump_input_buffer_patience : float
@export var idle_dive_sprite : Color
@export var max_diving_speed : int
@export_category("Animations")
@export var y_initial_sprite_stretch_multiplier : float
@export var x_initial_sprite_stretch_multiplier : float
@export var sprite_reset_speed : float
@export var y_final_sprite_stretch_multiplier : float
@export var x_final_sprite_stretch_multiplier : float

var jump_input_buffer : Timer
var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if abs(parent.velocity.x) > dive_horizontal_default_velocity:
		if abs(parent.velocity.x) < max_diving_speed:
			parent.velocity.x += dive_horizontal_additive_velocity * horizontal_input
	else:
		parent.velocity.x = dive_horizontal_default_velocity * horizontal_input
	parent.velocity.y = -dive_vertical_velocity
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed
	
	sprite.scale = Vector2(abs(x_initial_sprite_stretch_multiplier * parent.velocity.normalized().x),y_initial_sprite_stretch_multiplier * -parent.velocity.normalized().y)
	sprite.rotation = -parent.velocity.normalized().x

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_released("jump"):
		jump_input_buffer.stop()
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if parent.is_on_wall():
		return bonked_state
	if parent.is_on_floor():
		if jump_input_buffer.time_left > 0:
			return jumping_state
		else:
			return walking_state
	return null

func process_frame(_delta) -> State:
	sprite.scale = lerp(sprite.scale, Vector2(1,1), sprite_reset_speed)
	sprite.rotation = lerp(sprite.rotation, 0.45 * parent.velocity.normalized().x, sprite_reset_speed)
	return null

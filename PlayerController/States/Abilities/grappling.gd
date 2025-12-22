extends State

#States that Idle can transition to:
@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export_category("Parameters")
@export var grapple_duration : float #seconds
@export var grappling_speed: float
@export var jump_input_buffer_patience : float
@export_category("References")

@export var ray_up: RayCast2D
@export var ray_down: RayCast2D
@export var ray_left: RayCast2D
@export var ray_right: RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var jump_input_buffer: Timer
var grapple_timer: Timer

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	grapple_timer = Timer.new()
	grapple_timer.wait_time = grappling_speed
	grapple_timer.one_shot = true
	add_child(grapple_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	
	parent.velocity = Vector2(0,0)
	if direction == "up" and ray_up.is_colliding():
		print("up")
		parent.velocity.y = -grappling_speed
	elif direction == "down" and ray_down.is_colliding():
		print("down")
		parent.velocity.y = grappling_speed
	elif direction == "left" and ray_left.is_colliding():
		print("left")
		parent.velocity.x = -grappling_speed
	elif direction == "right" and ray_right.is_colliding():
		print("right")
		parent.velocity.x = grappling_speed

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	parent.move_and_slide()
	if parent.is_on_wall() or parent.is_on_ceiling():
		return falling_state
	if (parent.is_on_floor()):
		if jump_input_buffer.time_left > 0:
			return jumping_state
		if abs(parent.velocity.x) > 0:
			return walking_state
		else:
			return idle_state
	return null

func deactivate(_next_state) -> void:
	pass

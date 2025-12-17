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
@export var jump_input_buffer_patience : float
@export_category("References")
@export var grapple_ray: Node2D


var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var jump_input_buffer: Timer

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	
	parent.velocity = Vector2(0,0)
	if direction == "up":
		grapple_ray.rotation = 270
		print("yes")
	elif direction == "down":
		grapple_ray.rotation = 90
	elif direction == "left":
		grapple_ray.rotation = 180
	elif direction == "right":
		grapple_ray.rotation = 0

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

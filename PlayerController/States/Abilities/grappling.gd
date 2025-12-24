extends State

#States that Idle can transition to:
@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export var ascending_state : State
@export_category("Parameters")
@export var grapple_duration : float #seconds
@export var grappling_speed: float
@export var jump_input_buffer_patience : float
@export_category("References")

@export var grapple_max_length: float
@export var grapple_ray: RayCast2D
@export var line: Line2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var jump_input_buffer: Timer
var grapple_timer: Timer
var grapple_current_length: float
var has_collided = false

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	grapple_timer = Timer.new()
	grapple_timer.wait_time = grapple_duration
	grapple_timer.one_shot = true
	add_child(grapple_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	has_collided = false
	grapple_current_length = 0
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	parent.velocity = Vector2(0,0)


func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(delta) -> State:
	parent.move_and_slide()
	if !has_collided and grapple_current_length < grapple_max_length:
		grapple_current_length += 1500 * delta
		if grapple_current_length > grapple_max_length:
			grapple_current_length = grapple_max_length
		print(grapple_current_length)
		match direction:
			"right":
				grapple_ray.target_position = Vector2(grapple_current_length,0)
				line.set_point_position(1, Vector2(grapple_current_length,0))
			"left":
				grapple_ray.target_position = Vector2(-grapple_current_length,0)
				line.set_point_position(1, Vector2(-grapple_current_length,0))
			"up":
				grapple_ray.target_position = Vector2(0, -grapple_current_length)
				line.set_point_position(1, Vector2(0, -grapple_current_length))
			"down":
				grapple_ray.target_position = Vector2(0, grapple_current_length)
				line.set_point_position(1, Vector2(0, grapple_current_length))
		
		if grapple_ray.is_colliding():
			match direction:
				"right":
					parent.velocity.x = grappling_speed
				"left":
					parent.velocity.x = -grappling_speed
				"up":
					parent.velocity.y = -grappling_speed
				"down":
					parent.velocity.y = grappling_speed
			has_collided = true

	
	if (parent.is_on_wall() and parent.velocity == Vector2(0,0)) or parent.is_on_ceiling():
		return falling_state
	if (parent.velocity == Vector2(0,0) and has_collided):
		return falling_state
	if (parent.is_on_floor()):
		if jump_input_buffer.time_left > 0:
			return jumping_state
		else:
			return idle_state
	return null

func deactivate(_next_state) -> void:
	line.clear_points()

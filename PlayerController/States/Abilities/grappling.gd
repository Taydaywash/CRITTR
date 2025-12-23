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

@export var ray_up: RayCast2D
@export var ray_down: RayCast2D
@export var ray_left: RayCast2D
@export var ray_right: RayCast2D

@export var line_up: Line2D
@export var line_down: Line2D
@export var line_left: Line2D
@export var line_right: Line2D

@onready var rays : Array = [ray_left, ray_right, ray_up, ray_down]

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var jump_input_buffer: Timer
var grapple_timer: Timer
var no_collision = false

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
	grapple_timer.start()
	parent.velocity = Vector2(0,0)
	await grapple_timer.timeout
	#for ray in rays: 
		#if ray.is_colliding:
			#match direction:
				#"left":
					#parent.velocity.x = -grappling_speed
				#"right":
					#parent.velocity.x = grappling_speed
				#"up":
					#parent.velocity.y = -grappling_speed
				#"down":
					#parent.velocity.y = grappling_speed
				#_:
					#pass
					
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
	else:
		no_collision = true

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	parent.move_and_slide()
	if (parent.is_on_wall() and parent.velocity == Vector2(0,0)) or parent.is_on_ceiling():
		return falling_state
	if (parent.velocity == Vector2(0,0) and grapple_timer.time_left == 0):
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

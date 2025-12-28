extends State
@export_category("States")
@export var falling_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export var ascending_state : State
@export var idle_state : State

@export_category("Parameters")
@export var jump_input_buffer_patience : float
@export var climbing_input_buffer_patience: float
@export var max_speed: float
@export var speed_increment: float
@export var push_target_length: float 

@export_category("References")
@export var climbing_ray: RayCast2D
@export var line: Line2D

var jump_input_buffer: Timer
var climbing_input_buffer: Timer
var direction : String

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	climbing_input_buffer = Timer.new()
	climbing_input_buffer.wait_time = climbing_input_buffer_patience
	climbing_input_buffer.one_shot = true
	add_child(climbing_input_buffer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	
	match direction:
			"right":
				climbing_ray.target_position = Vector2(push_target_length,0)
				line.set_point_position(1, Vector2(push_target_length,0))
			"left":
				climbing_ray.target_position = Vector2(-push_target_length,0)
				line.set_point_position(1, Vector2(-push_target_length,0))
			"up":
				climbing_ray.target_position = Vector2(0, -push_target_length)
				line.set_point_position(1, Vector2(0, -push_target_length))
			"down":
				climbing_ray.target_position = Vector2(0, push_target_length)
				line.set_point_position(1, Vector2(0, push_target_length))
				parent.velocity.y = 1000

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	parent.move_and_slide()
	
	if climbing_ray.is_colliding():
		print("collided")
		
		if parent.is_on_floor():
			if sprite.flip_h == true:
				parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
			elif sprite.flip_h == false: 
				parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
		else:
			return falling_state
		
	#if direction == "down" and parent.is_on_floor():
		#if sprite.flip_h == true:
			#parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
		#elif sprite.flip_h == false: 
			#parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
	#else:
		#return falling_state
		
	
		
	if direction == "up" and climbing_ray.is_colliding():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
	
	
	
	if (parent.is_on_floor()):
		if jump_input_buffer.time_left > 0:
			return jumping_state
		#elif parent.velocity == Vector2(0,0):
			#return idle_state 
			
			
	#if (!parent.is_on_floor() and climbing_timer.time_left == 0):
		#return ascending_state
	
	return null

func deactivate(_next_state) -> void:
	climbing_ray.target_position = Vector2.ZERO
	line.clear_points()

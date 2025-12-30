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
@export var max_speed: float
@export var speed_increment: float 
@export var bounce_velocity: float

@export_category("Wall detection rays")
@export var right_ray : RayCast2D
@export var left_ray : RayCast2D

var jump_input_buffer: Timer
var climbing_input_buffer: Timer
var direction : String

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:c

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	match direction:
		"up":
			parent.velocity.y = -1
		"down":
			parent.velocity.y = 1
		"right":
			parent.velocity.x = 1
		"left":
			parent.velocity.x = -1

	parent.move_and_slide()

	if direction == "down" and parent.is_on_floor():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
	elif direction == "up" and parent.is_on_ceiling():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
	elif direction == "right" and parent.is_on_wall():
		parent.velocity.y = move_toward(parent.velocity.y, -max_speed, speed_increment)
	elif direction == "left" and parent.is_on_wall():
		parent.velocity.y = move_toward(parent.velocity.y, -max_speed, speed_increment)
	else:
		return falling_state
		
	if jump_input_buffer.time_left > 0:
		return jumping_state
	#if (parent.is_on_ceiling() or parent.is_on_floor()) and parent.is_on_wall():
		#return falling_state
		
	#if parent.is_on_ceiling() and direction != "up":
		#parent.velocity.y = bounce_velocity
		#return falling_state
	#if parent.is_on_wall() and (direction != "right" or direction != "left"):
		#if sprite.flip_h == true:
			#parent.velocity.x = -bounce_velocity
		#if sprite.flip_h == false:
			#parent.velocity.x = bounce_velocity
		#return falling_state
	
	return null

func deactivate(_next_state) -> void:
	pass

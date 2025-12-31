extends State
@export_category("States")
@export var falling_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export var ascending_state : State
@export var idle_state : State
@export var wall_jumping_state: State

@export_category("Parameters")
@export var jump_input_buffer_patience : float
@export var max_speed: float
@export var speed_increment: float 
@export var bounce_velocity: float

@export_category("References")
@export var climbing_ray: RayCast2D


@export_category("Colliders")
@export var default_hitbox : CollisionShape2D
@export var crouching_hitbox : CollisionShape2D

var jump_input_buffer: Timer
var climbing_input_buffer: Timer
var direction : String
var one_frame_passed : bool = false
var last_position: Vector2

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
	change_collider_to(crouching_hitbox)
	parent.set_collision_mask_value(6,false)
	one_frame_passed = false

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	match direction:
		"up":
			parent.velocity.y = -speed_increment
		"down":
			parent.velocity.y = speed_increment
		"right":
			parent.velocity.x = speed_increment
		"left":
			parent.velocity.x = -speed_increment
	
	parent.move_and_slide()

	if direction == "down" and parent.is_on_floor():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
			climbing_ray.target_position = Vector2(-30,0)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
			climbing_ray.target_position = Vector2(30,0)
	elif direction == "up" and parent.is_on_ceiling():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -max_speed, speed_increment)
			climbing_ray.target_position = Vector2(-30,0)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, max_speed, speed_increment)
			climbing_ray.target_position = Vector2(30,0)
	elif direction == "right" and parent.is_on_wall():
		parent.velocity.y = move_toward(parent.velocity.y, -max_speed, speed_increment)
		climbing_ray.target_position = Vector2(0, -40)
	elif direction == "left" and parent.is_on_wall():
		parent.velocity.y = move_toward(parent.velocity.y, -max_speed, speed_increment)
		climbing_ray.target_position = Vector2(0, -40)
	else:
		if parent.velocity.y < 0:
			return ascending_state
		return falling_state
		
	if climbing_ray.is_colliding():
		return falling_state
		
	if jump_input_buffer.time_left > 0:
		if parent.is_on_wall():
			return wall_jumping_state
		return jumping_state
		
	if one_frame_passed:
		return null
	else:
		one_frame_passed = true
	
	return null

func deactivate(_next_state) -> void:
	super(_next_state)
	change_collider_to(default_hitbox)
	parent.set_collision_mask_value(6,true)
	climbing_ray.target_position = Vector2.ZERO

extends State

@export_category("Parameters")
@export var jump_input_buffer_patience : float
@export var max_speed: float
@export var speed_increment: float 

@export_category("References")
@export var climbing_ray: RayCast2D
@export var climbing_buffer_state : State

@export_category("Colliders")
@export var default_hitbox : CollisionShape2D
@export var crouching_hitbox : CollisionShape2D
@export var ceiling_detection : RayCast2D
@export var floor_detection : RayCast2D
@export var floor_detection_2 : RayCast2D
@export var left_ray : RayCast2D
@export var right_ray : RayCast2D

var jump_input_buffer: Timer
var climbing_input_buffer: Timer
var direction : String
var last_position: Vector2
var pre_velocity_speed_set: bool = false

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
	match direction:
		"up":
			player.velocity.x = climbing_buffer_state.pre_slide_velocity.x
			player.velocity.y = -10
		"down":
			player.velocity.x = climbing_buffer_state.pre_slide_velocity.x
			player.velocity.y = 10
		"right":
			player.velocity.y = climbing_buffer_state.pre_slide_velocity.y
			player.velocity.x = 10
		"left":
			player.velocity.y = climbing_buffer_state.pre_slide_velocity.y
			player.velocity.x = -10
	if player.velocity.y > 500:
		player.velocity.y = 500
	pre_velocity_speed_set = true

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	player.move_and_slide()
	if not pre_velocity_speed_set:
		return
	match direction:
		"up":
			player.velocity.y = -10
		"down":
			player.velocity.y = 10
		"right":
			player.velocity.x = 10
		"left":
			player.velocity.x = -10
	if direction == "down" and (player.is_on_floor() or floor_detection.is_colliding()):
		if sprite.flip_h == true:
			player.velocity.x = move_toward(player.velocity.x, -max_speed, speed_increment)
			climbing_ray.target_position = Vector2(-30,0)
		elif sprite.flip_h == false: 
			player.velocity.x = move_toward(player.velocity.x, max_speed, speed_increment)
			climbing_ray.target_position = Vector2(30,0)
	elif direction == "up" and (player.is_on_ceiling() or ceiling_detection.is_colliding()):
		if sprite.flip_h == true:
			player.velocity.x = move_toward(player.velocity.x, -max_speed, speed_increment)
			climbing_ray.target_position = Vector2(-30,0)
		elif sprite.flip_h == false: 
			player.velocity.x = move_toward(player.velocity.x, max_speed, speed_increment)
			climbing_ray.target_position = Vector2(30,0)
	elif direction == "right" and (player.is_on_wall() or right_ray.is_colliding()):
		player.velocity.y = move_toward(player.velocity.y, -max_speed, speed_increment)
		climbing_ray.target_position = Vector2(0, -40)
	elif direction == "left" and (player.is_on_wall() or left_ray.is_colliding()):
		player.velocity.y = move_toward(player.velocity.y, -max_speed, speed_increment)
		climbing_ray.target_position = Vector2(0, -40)
	elif jump_input_buffer.time_left > 0:
		if player.is_on_wall() or left_ray.is_colliding() or right_ray.is_colliding():
			return wall_jumping_state
		return jumping_state
	else:
		if player.velocity.y < 0:
			return ascending_state
		return falling_state
		
	if jump_input_buffer.time_left > 0:
		match direction:
			"up":
				if floor_detection.is_colliding() or floor_detection_2.is_colliding():
					return
			"down":
				if ceiling_detection.is_colliding():
					return
		if player.is_on_wall() or left_ray.is_colliding() or right_ray.is_colliding():
			return wall_jumping_state
		return jumping_state
		
	if climbing_ray.is_colliding():
		return falling_state

	return null

func deactivate(_next_state) -> void:
	super(_next_state)
	match direction:
		"left":
			player.position.x += 10
		"right":
			player.position.x -= 10
	pre_velocity_speed_set = false
	change_collider_to(default_hitbox)
	climbing_ray.target_position = Vector2.ZERO

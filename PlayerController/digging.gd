extends State

@export var icon : CompressedTexture2D

@export_category("States")
@export var jumping_state : State
@export_category("Parameters")
@export var wind_up_delay : float
@export var wind_up_velocity : float
@export var initial_velocity : float
@export var turn_speed : float
@export_category("Colliders")
@export var crouching_hitbox : CollisionShape2D
@export var normal_hitbox : CollisionShape2D

var direction : String
var winding_up : bool

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(_last_state : State) -> void:
	super(_last_state)
	winding_up = true
	change_collider_to(crouching_hitbox)
	parent.velocity = Vector2(0,0)
	
	if direction == "up":
		parent.velocity.y = wind_up_velocity
	elif direction == "down":
		parent.velocity.y = -wind_up_velocity
	elif direction == "left":
		parent.velocity.x = wind_up_velocity
	elif direction == "right":
		parent.velocity.x = -wind_up_velocity
	await get_tree().create_timer(wind_up_delay).timeout
	winding_up = false
	if direction == "up":
		parent.velocity.y = -initial_velocity
	elif direction == "down":
		parent.velocity.y = initial_velocity
	elif direction == "left":
		parent.velocity.x = -initial_velocity
	elif direction == "right":
		parent.velocity.x = initial_velocity

func process_input(event) -> State:
	if event.is_action_pressed("jump"):
		return jumping_state
	return null

func process_physics(delta) -> State:
	if winding_up:
		parent.move_and_slide()
		return null
	
	var new_angle_degrees : float = parent.velocity.angle()
	var new_angle_vector : Vector2
	if Input.is_action_pressed("move_up"):
		new_angle_degrees = lerp_angle(parent.velocity.angle(),Vector2(0,-1).angle(),clampf(turn_speed * delta,0.0,1.0))
	if Input.is_action_pressed("move_down"):
		new_angle_degrees = lerp_angle(parent.velocity.angle(),Vector2(0,1).angle(),clampf(turn_speed * delta,0.0,1.0))
	if Input.is_action_pressed("move_left"):
		new_angle_degrees = lerp_angle(parent.velocity.angle(),Vector2(-1,0).angle(),clampf(turn_speed * delta,0.0,1.0))
	if Input.is_action_pressed("move_right"):
		new_angle_degrees = lerp_angle(parent.velocity.angle(),Vector2(1,0).angle(),clampf(turn_speed * delta,0.0,1.0))
	new_angle_vector = Vector2(cos(new_angle_degrees),sin(new_angle_degrees)).normalized()
	
	parent.velocity = new_angle_vector * initial_velocity
	parent.move_and_slide()
	return null

func deactivate(_next_state : State) -> void:
	super(_next_state)
	change_collider_to(normal_hitbox)

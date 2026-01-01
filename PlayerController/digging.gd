extends State

@export_category("States")
@export var jumping_state : State
@export var ascending_state : State
@export_category("Parameters")
@export var dig_speed : float
@export var turn_speed : float
@export var wall_exit_speed_multiplier : float
@export_category("Colliders")
@export var crouching_hitbox : CollisionShape2D
@export var normal_hitbox : CollisionShape2D
@export_category("Raycasts")
@export var drill_ray : RayCast2D
@export var drill_ray_not_digable : RayCast2D
@export var forward_detection_range : float
@export var backwards_offset : float
@export var line: Line2D

var direction : String
var one_frame_passed : bool
var new_angle_degrees : float
var new_angle_vector : Vector2

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(_last_state : State) -> void:
	super(_last_state)
	player.z_index = 2
	one_frame_passed = false
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	player.set_collision_mask_value(7,false)
	change_collider_to(crouching_hitbox)
	player.velocity = Vector2(0,0)
	if direction == "up":
		player.velocity.y = -dig_speed
	elif direction == "down":
		player.velocity.y = dig_speed
	elif direction == "left":
		player.velocity.x = -dig_speed
	elif direction == "right":
		player.velocity.x = dig_speed

func process_physics(delta) -> State:
	new_angle_degrees = player.velocity.angle()
	if Input.is_action_pressed("move_up"):
		new_angle_degrees = lerp_angle(player.velocity.angle(),Vector2(0,-1).angle(),clampf(turn_speed * delta,0.0,1.0))
	if Input.is_action_pressed("move_down"):
		new_angle_degrees = lerp_angle(player.velocity.angle(),Vector2(0,1).angle(),clampf(turn_speed * delta,0.0,1.0))
	if Input.is_action_pressed("move_left"):
		new_angle_degrees = lerp_angle(player.velocity.angle(),Vector2(-1,0).angle(),clampf(turn_speed * delta,0.0,1.0))
	if Input.is_action_pressed("move_right"):
		new_angle_degrees = lerp_angle(player.velocity.angle(),Vector2(1,0).angle(),clampf(turn_speed * delta,0.0,1.0))
	new_angle_vector = Vector2(cos(new_angle_degrees),sin(new_angle_degrees)).normalized()
	
	drill_ray.target_position = new_angle_vector * forward_detection_range
	drill_ray.position = new_angle_vector * -backwards_offset
	drill_ray_not_digable.target_position = drill_ray.target_position
	drill_ray_not_digable.position = new_angle_vector * -backwards_offset
	line.set_point_position(1, drill_ray.target_position)
	player.velocity = new_angle_vector * dig_speed
	var pre_slide_velocity = player.velocity
	player.move_and_slide()
	if player.is_on_wall():
		player.velocity.x = -pre_slide_velocity.x
	if player.is_on_floor() or player.is_on_ceiling():
		player.velocity.y = -pre_slide_velocity.y
	if can_exit_state():
		if Input.is_action_pressed("jump"):
			return jumping_state
		if one_frame_passed:
			return ascending_state
		else:
			one_frame_passed = true
	return null

func can_exit_state() -> bool:
	if drill_ray.is_colliding() or drill_ray_not_digable.is_colliding():
		return false
	return true

func process_frame(_delta) -> State:
	sprite.rotation = new_angle_degrees + PI/2 
	return null

func deactivate(_next_state : State) -> void:
	super(_next_state)
	player.z_index = 0
	player.velocity = player.velocity * wall_exit_speed_multiplier
	change_collider_to(normal_hitbox)
	line.clear_points()
	player.set_collision_mask_value(7,true)

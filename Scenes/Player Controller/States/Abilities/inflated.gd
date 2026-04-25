extends State

@export var icon : CompressedTexture2D

#States that Idle can transition to:
@export_category("Initial Velocity")
@export var initial_velocity : float
@export var additive_velocity : float
@export_category("Parameters")
@export var bounce_velocity : float
@export var inflated_duration : float #seconds
@export var bounce_timer_reduction : float #seconds
@export var vertical_velocity_dampen_multiplier : float
@export var horizontal_velocity_dampen_multiplier : float
@export var upwards_acceleration : float
@export var max_ascent_speed : float
@export var max_move_speed : float
@export var horizontal_acceleration : float
@export var horizontal_decceleration : float
@export var can_exit_state_delay : float
@export_category("Animation")
@export var grow_speed : float
@export var color_return_speed : float
@export_category("Wall detection rays")
@export var left_ray : RayCast2D
@export var left_ray_low : RayCast2D
@export var left_ray_high : RayCast2D
@export var right_ray : RayCast2D
@export var right_ray_low : RayCast2D
@export var right_ray_high : RayCast2D
@export_category("Colliders")
@export var normal_hitbox : CollisionShape2D
@export var normal_hurtbox : Area2D
@export var inflated_hitbox : CollisionShape2D
@export var inflated_hurtbox : Area2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var inflated_duration_timer : Timer
var can_exit_state : bool = false

func _ready() -> void:
	#Dash timer setup:
	inflated_duration_timer = Timer.new()
	inflated_duration_timer.one_shot = true
	add_child(inflated_duration_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	can_exit_state = false
	change_collider_to(inflated_hitbox)
	change_hurtbox_to(inflated_hurtbox)
	EventController.emit_signal("entered_inflate_state")
	sprite.offset.y = -50
	if direction == "up":
		inflated_duration_timer.wait_time = inflated_duration
		player.velocity.x /= horizontal_velocity_dampen_multiplier
		inflated_duration_timer.start()
		player.velocity.y = -initial_velocity
	elif direction == "down":
		inflated_duration_timer.wait_time = inflated_duration
		player.velocity.x /= horizontal_velocity_dampen_multiplier
		inflated_duration_timer.start()
		player.velocity.y = initial_velocity
	elif direction == "left":
		inflated_duration_timer.wait_time = inflated_duration
		player.velocity.y /= vertical_velocity_dampen_multiplier
		inflated_duration_timer.start()
		if abs(player.velocity.x) > initial_velocity and player.velocity.x < 0:
			player.velocity.x += -additive_velocity
		else:
			player.velocity.x = -initial_velocity
	elif direction == "right":
		inflated_duration_timer.wait_time = inflated_duration
		player.velocity.y /= vertical_velocity_dampen_multiplier
		inflated_duration_timer.start()
		if abs(player.velocity.x) > initial_velocity and player.velocity.x > 0:
			player.velocity.x += additive_velocity
		else:
			player.velocity.x = initial_velocity
	await get_tree().create_timer(can_exit_state_delay).timeout
	can_exit_state = true
		
func process_input(event : InputEvent) -> State:
	if not can_exit_state:
		return
	if event.is_action_pressed("use_ability"):
		return ability_state
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(delta) -> State:
	var velocity_before_slide : Vector2 = player.velocity
	if player.velocity.y > -max_ascent_speed:
		player.velocity.y = player.velocity.move_toward(Vector2(player.velocity.x,-max_ascent_speed),upwards_acceleration * delta).y
	if player.velocity.y > 0:
		player.velocity.y /= 1.01
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(player.velocity.x) < max_move_speed) or (sign(horizontal_input) != sign(player.velocity.x)):
		player.velocity.x += horizontal_acceleration * delta * horizontal_input
	else:
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),horizontal_decceleration * delta).x
	if horizontal_input == 0:
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),horizontal_decceleration * delta).x
	player.move_and_slide()
	
	if player.is_on_ceiling():
		player.velocity.y = bounce_velocity
		bounced()
	if player.is_on_wall():
		if (left_ray.is_colliding() or left_ray_low.is_colliding() or left_ray_high.is_colliding()) and velocity_before_slide.x < -10:
			player.velocity.x = bounce_velocity
			bounced()
		elif (right_ray.is_colliding() or right_ray_low.is_colliding() or right_ray_high.is_colliding()) and velocity_before_slide.x > 10:
			player.velocity.x = -bounce_velocity
			bounced()
	if player.is_on_floor():
		player.velocity.y = -bounce_velocity
		bounced()
	if inflated_duration_timer.time_left == 0:
		if player.velocity.y < 0:
			return ascending_state
		return falling_state
	return null

func process_frame(delta) -> State:
	sprite.scale = sprite.scale.move_toward(Vector2(1.5,1.5),grow_speed * delta)

	player.modulate = lerp(player.modulate, Color(1,1,1), color_return_speed)
	if inflated_duration_timer.time_left < 0.5:
		if (fmod(snapped(inflated_duration_timer.time_left, 0.1), 0.2) == 0):
			player.modulate = Color(1,0,0)
	elif inflated_duration_timer.time_left < 1.0:
		if (fmod(snapped(inflated_duration_timer.time_left, 0.1), 0.4) == 0):
			player.modulate = Color(1,0,0)
	elif inflated_duration_timer.time_left < 2.0:
		if (fmod(snapped(inflated_duration_timer.time_left, 0.1), 0.5) == 0):
			player.modulate = Color(1,0,0)
	return null

func bounced():
	if inflated_duration_timer.time_left - bounce_timer_reduction > 0:
		inflated_duration_timer.wait_time = inflated_duration_timer.time_left - bounce_timer_reduction
		inflated_duration_timer.start()
	else:
		inflated_duration_timer.stop()

func deactivate(next_state : State) -> void:
	super(next_state)
	EventController.emit_signal("exited_inflate_state")
	sprite.offset.y = -70
	sprite.scale.x = 1
	sprite.scale.y = 1
	change_hurtbox_to(normal_hurtbox)
	change_collider_to(normal_hitbox)

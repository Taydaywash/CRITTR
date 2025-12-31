extends State

@export var icon : CompressedTexture2D

#States that Idle can transition to:
@export_category("States")
@export var jumping_state : State
@export var walking_state : State
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var ascending_state : State
@export_category("Initial Velocity")
@export var initial_up_velocity : float
@export var additive_initial_up_velocity : float
@export var initial_down_velocity : float
@export var additive_initial_down_velocity : float
@export var initial_horizontal_velocity : float
@export var additive_initial_horizontal_velocity : float
@export_category("Parameters")
@export var bounce_velocity : float
@export var inflated_duration : float #seconds
@export var bounce_timer_reduction : float #seconds
@export var horizontal_ascent_reduction_percentage : float
@export var ascent_speed : float
@export var max_ascent_speed : float
@export var max_move_speed : float
@export var acceleration_speed : float
@export var decceleration_speed : float
@export_category("Animation")
@export var color_return_speed : float
@export_category("Wall detection rays")
@export var left_ray : RayCast2D
@export var right_ray : RayCast2D

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var inflated_duration_timer : Timer

func _ready() -> void:
	#Dash timer setup:
	inflated_duration_timer = Timer.new()
	inflated_duration_timer.one_shot = true
	add_child(inflated_duration_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	if direction == "up":
		inflated_duration_timer.wait_time = inflated_duration
		inflated_duration_timer.start()
		parent.velocity.y = -initial_up_velocity
		#if parent.velocity.y > 0:
			#parent.velocity.y -= initial_up_velocity
		#elif parent.velocity.y < initial_up_velocity:
			#parent.velocity.y -= additive_initial_up_velocity
		#else:
			#parent.velocity.y = -initial_up_velocity
	elif direction == "down":
		inflated_duration_timer.wait_time = inflated_duration
		inflated_duration_timer.start()
		parent.velocity.y = initial_down_velocity
		#if parent.velocity.y > initial_down_velocity:
			#parent.velocity.y += additive_initial_down_velocity
		#else:
			#parent.velocity.y = initial_down_velocity
	elif direction == "left":
		inflated_duration_timer.wait_time = inflated_duration - bounce_timer_reduction
		parent.velocity.y = parent.velocity.y / 10
		inflated_duration_timer.start()
		if abs(parent.velocity.x) > initial_horizontal_velocity:
			parent.velocity.x = -additive_initial_horizontal_velocity
		else:
			parent.velocity.x = -initial_horizontal_velocity
	elif direction == "right":
		inflated_duration_timer.wait_time = inflated_duration - bounce_timer_reduction
		parent.velocity.y = parent.velocity.y / 10
		inflated_duration_timer.start()
		if abs(parent.velocity.x) > initial_horizontal_velocity:
			parent.velocity.x = additive_initial_horizontal_velocity
		else:
			parent.velocity.x = initial_horizontal_velocity

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		return jumping_state
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(delta) -> State:
	if parent.velocity.y > -max_ascent_speed:
		parent.velocity.y -= (ascent_speed - abs(parent.velocity.x * horizontal_ascent_reduction_percentage)) * delta 
		
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(parent.velocity.x) < max_move_speed) or (sign(horizontal_input) != sign(parent.velocity.x)):
		parent.velocity.x += acceleration_speed * delta * horizontal_input
	else:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	if horizontal_input == 0:
		parent.velocity.x = parent.velocity.move_toward(Vector2(0,0),decceleration_speed * delta).x
	parent.move_and_slide()
	
	if parent.is_on_ceiling():
		parent.velocity.y = bounce_velocity
		bounced()
	if parent.is_on_wall():
		if left_ray.is_colliding():
			parent.velocity.x = bounce_velocity
			bounced()
		elif right_ray.is_colliding():
			parent.velocity.x = -bounce_velocity
			bounced()
	if parent.is_on_floor():
		parent.velocity.y = -bounce_velocity
		bounced()
	if inflated_duration_timer.time_left == 0:
		return falling_state
	return null

func process_frame(_delta) -> State:
	parent.modulate = lerp(parent.modulate, Color(1,1,1), color_return_speed)
	if inflated_duration_timer.time_left < 0.5:
		if (fmod(snapped(inflated_duration_timer.time_left, 0.1), 0.2) == 0):
			parent.modulate = Color(1,0,0)
	elif inflated_duration_timer.time_left < 1.0:
		if (fmod(snapped(inflated_duration_timer.time_left, 0.1), 0.4) == 0):
			parent.modulate = Color(1,0,0)
	elif inflated_duration_timer.time_left < 2.0:
		if (fmod(snapped(inflated_duration_timer.time_left, 0.1), 0.5) == 0):
			parent.modulate = Color(1,0,0)
	return null

func bounced():
	if inflated_duration_timer.time_left - bounce_timer_reduction > 0:
		inflated_duration_timer.wait_time = inflated_duration_timer.time_left - bounce_timer_reduction
		inflated_duration_timer.start()
	else:
		inflated_duration_timer.stop()

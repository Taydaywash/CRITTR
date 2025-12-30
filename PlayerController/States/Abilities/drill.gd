extends State

@export var icon : CompressedTexture2D

@export_category("States")
@export var falling_state : State
@export var digging_state : State
@export_category("Parameters")
@export var wind_up_delay : float
@export var wind_up_velocity : float
@export var initial_velocity : float
@export var turn_speed : float
@export var wall_detection_grace : float
@export_category("Raycasts")
@export var drill_ray : RayCast2D
@export var drill_ray_not_digable : RayCast2D
@export var forward_detection_range : float
@export var backwards_offset : float
@export var line: Line2D

var direction : String
var winding_up : bool
var new_angle_degrees : float
var new_angle_vector : Vector2
var wall_detection_timer : Timer

func _ready() -> void:
	wall_detection_timer = Timer.new()
	wall_detection_timer.wait_time = wall_detection_grace
	wall_detection_timer.one_shot = true
	add_child(wall_detection_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(_last_state : State) -> void:
	super(_last_state)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	winding_up = true
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
	wall_detection_timer.start()
	winding_up = false
	if direction == "up":
		parent.velocity.y = -initial_velocity
	elif direction == "down":
		parent.velocity.y = initial_velocity
	elif direction == "left":
		parent.velocity.x = -initial_velocity
	elif direction == "right":
		parent.velocity.x = initial_velocity
	new_angle_degrees = parent.velocity.angle()

func process_physics(_delta) -> State:
	if winding_up:
		parent.move_and_slide()
		return null
	drill_ray.target_position = new_angle_vector * forward_detection_range
	drill_ray.position = new_angle_vector * -backwards_offset
	drill_ray_not_digable.target_position = drill_ray.target_position
	drill_ray_not_digable.position = new_angle_vector * -backwards_offset

	new_angle_vector = Vector2(cos(new_angle_degrees),sin(new_angle_degrees)).normalized()
	line.set_point_position(1, drill_ray.target_position)
	parent.velocity = new_angle_vector * initial_velocity
	parent.move_and_slide()

	if drill_ray.is_colliding():
		drill_ray.target_position = drill_ray.to_local(drill_ray.get_collision_point())
		drill_ray_not_digable.target_position = drill_ray.target_position
		if parent.get_slide_collision_count() > 0:
			if drill_ray_not_digable.is_colliding():
				return falling_state
			return digging_state
	elif wall_detection_timer.time_left == 0:
		return falling_state
	return null

func process_frame(_delta) -> State:
	sprite.rotation = new_angle_degrees + PI/2
	return null

func deactivate(_next_state : State) -> void:
	super(_next_state)
	line.clear_points()

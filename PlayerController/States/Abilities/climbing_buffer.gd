extends State

@export var icon : CompressedTexture2D

@export_category("States")
@export var climbing_state: State
@export var falling_state: State

@export_category("Parameters")
@export var climbing_input_buffer_patience: float
@export var push_target_length: float 
@export var push_speed: float

@export_category("References")
@export var climbing_ray: RayCast2D
@export var line: Line2D

@export_category("Colliders")
@export var default_hitbox : CollisionShape2D
@export var crouching_hitbox : CollisionShape2D

var climbing_input_buffer: Timer
var direction : String
var gravity : float
var max_falling_speed : float

func _ready() -> void:
	climbing_input_buffer = Timer.new()
	climbing_input_buffer.wait_time = climbing_input_buffer_patience
	climbing_input_buffer.one_shot = true
	add_child(climbing_input_buffer)
	
func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed
	climbing_ray.reparent(parent, false)
	
	super(last_state) #Call activate as defined in state.gd and then also do:
	change_collider_to(crouching_hitbox)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	climbing_input_buffer.start()
	
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
				

func process_input(_event : InputEvent) -> State:
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed and not climbing_ray.is_colliding():
		parent.velocity.y += gravity * delta
	parent.move_and_slide()
	if climbing_ray.is_colliding():
		match direction:
			"right":
				parent.velocity.x = push_speed
				parent.velocity.y = 0
			"left":
				parent.velocity.x = -push_speed
				parent.velocity.y = 0
			"up":
				parent.velocity.y = -push_speed
				parent.velocity.x = 0
			"down":
				parent.velocity.y = push_speed
				parent.velocity.x = 0
	elif climbing_input_buffer.time_left == 0:
		return falling_state
	if parent.get_slide_collision_count() > 0:
		return climbing_state
	return null
	

func deactivate(_next_state) -> void:
	super(_next_state)
	change_collider_to(default_hitbox)
	climbing_ray.target_position = Vector2.ZERO
	line.clear_points()

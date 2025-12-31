extends State

@export var icon : CompressedTexture2D

#States that Idle can transition to:
@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export var ascending_state : State

@export_category("Parameters")
@export var grapple_duration : float #seconds
@export var grappling_speed: float
@export var grapple_max_length: float
@export var grapple_increment: float
@export var jump_input_buffer_patience : float

@export_category("References")
@export var grapple_ray: RayCast2D
@export var line: Line2D

var direction : String
var jump_input_buffer: Timer
var grapple_current_length: float
var global_point: Vector2

func _ready() -> void:
	pass

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	global_point = grapple_ray.get_collision_point()

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	grapple_ray.target_position = grapple_ray.to_local(grapple_ray.get_collision_point())
	line.set_point_position(1, grapple_ray.to_local(grapple_ray.get_collision_point()))
	parent.move_and_slide()
	
	if direction == "up" and parent.global_position.y < global_point.y:
		return ascending_state
	elif direction == "down" and parent.global_position.y > global_point.y:
		return falling_state
	elif direction == "right" and parent.global_position.x > global_point.x:
		return falling_state
	elif direction == "left" and parent.global_position.x < global_point.x:
		return falling_state
	
	if parent.get_slide_collision_count() > 0:
		return falling_state

	return null

func deactivate(_next_state) -> void:
	grapple_ray.target_position = Vector2.ZERO
	line.clear_points()

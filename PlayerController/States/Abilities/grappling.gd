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
@export var grappling_pull_state: State

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
var grapple_timer: Timer
var grapple_current_length: float
var has_collided: bool = false

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	grapple_timer = Timer.new()
	grapple_timer.wait_time = grapple_duration
	grapple_timer.one_shot = true
	add_child(grapple_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	has_collided = false
	grapple_current_length = 0
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	player.velocity = Vector2(0,0)


func process_input(_event : InputEvent) -> State:
	#if event.is_action_pressed("jump"):
		#jump_input_buffer.start()
	#if event.is_action_pressed("dive"):
		#return diving_state
	return null

func process_physics(delta) -> State:
	
	player.move_and_slide()
	if !has_collided and grapple_current_length < grapple_max_length:
		grapple_current_length += grapple_increment * delta
		if grapple_current_length > grapple_max_length:
			grapple_current_length = grapple_max_length

		match direction:
			"right":
				grapple_ray.target_position = Vector2(grapple_current_length,0)
				line.set_point_position(1, Vector2(grapple_current_length,0))
			"left":
				grapple_ray.target_position = Vector2(-grapple_current_length,0)
				line.set_point_position(1, Vector2(-grapple_current_length,0))
			"up":
				grapple_ray.target_position = Vector2(0, -grapple_current_length)
				line.set_point_position(1, Vector2(0, -grapple_current_length))
			"down":
				grapple_ray.target_position = Vector2(0, grapple_current_length)
				line.set_point_position(1, Vector2(0, grapple_current_length))
		
		if grapple_ray.is_colliding():
			match direction:
				"right":
					player.velocity.x = grappling_speed
				"left":
					player.velocity.x = -grappling_speed
				"up":
					player.velocity.y = -grappling_speed
				"down":
					player.velocity.y = grappling_speed
			has_collided = true
			return grappling_pull_state

	elif (!has_collided and grapple_current_length == grapple_max_length):
		line.clear_points()
		return falling_state
	elif (has_collided and player.velocity.x == 0):
		line.clear_points()
		return falling_state
	
	if (player.is_on_floor()):
		if jump_input_buffer.time_left > 0:
			line.clear_points()
			return jumping_state
		elif has_collided and player.velocity == Vector2(0,0):
			line.clear_points()
			return idle_state
	return null

func deactivate(_next_state) -> void:
	pass

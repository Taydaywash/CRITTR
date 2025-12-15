extends State

#States that Idle can transition to:
@export var jumping_state : State
@export var falling_state : State
@export var diving_state : State

@export var dashing_speed : int
@export var dash_duration : float #seconds
@export var dash_end_velocity_multiplier : float

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
var direction : String
var dash_timer : Timer

func _ready() -> void:
	dash_timer = Timer.new()
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	add_child(dash_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	dash_timer.start()
	parent.velocity = Vector2(0,0)
	if direction == "up":
		parent.velocity.y = -dashing_speed
	if direction == "down":
		parent.velocity.y = dashing_speed
	if direction == "left":
		parent.velocity.x = -dashing_speed
	if direction == "right":
		parent.velocity.x = dashing_speed

func process_input(_event : InputEvent) -> State:
	if Input.is_action_just_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	parent.move_and_slide()
	if parent.is_on_wall() or parent.is_on_ceiling() or parent.is_on_floor() or dash_timer.time_left == 0:
		return falling_state
	return null

func deactivate() -> void:
	parent.velocity.x = parent.velocity.x * dash_end_velocity_multiplier 
	parent.velocity.y = parent.velocity.y * dash_end_velocity_multiplier 

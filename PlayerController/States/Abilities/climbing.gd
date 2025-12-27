extends State
@export_category("States")
@export var falling_state : State
@export var diving_state : State
@export var jumping_state : State
@export var walking_state : State
@export var ascending_state : State
@export var idle_state : State

@export_category("Parameters")
@export var jump_input_buffer_patience : float
@export var climbing_duration: float

var jump_input_buffer: Timer
var climbing_timer: Timer
var direction : String

func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	climbing_timer = Timer.new()
	climbing_timer.wait_time = climbing_duration
	climbing_timer.one_shot = true
	add_child(climbing_timer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	climbing_timer.start()

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump"):
		jump_input_buffer.start()
	if event.is_action_pressed("dive"):
		return diving_state
	return null

func process_physics(_delta) -> State:
	parent.move_and_slide()
	
	if direction == "down" and parent.is_on_floor():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -2000, 20)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, 2000, 20)
	else: 
		return idle_state
		
	if direction == "up" and parent.is_on_ceiling():
		if sprite.flip_h == true:
			parent.velocity.x = move_toward(parent.velocity.x, -2000, 20)
		elif sprite.flip_h == false: 
			parent.velocity.x = move_toward(parent.velocity.x, 2000, 20)
	else:
		return falling_state
	
	
	
	if (parent.is_on_floor()):
		if jump_input_buffer.time_left > 0:
			return jumping_state
		elif parent.velocity == Vector2(0,0):
			pass
			#return idle_state 
	if climbing_timer.time_left == 0:
		return falling_state
			
			
	#if (!parent.is_on_floor() and climbing_timer.time_left == 0):
		#return ascending_state
	
	return null

func deactivate(_next_state) -> void:
	pass

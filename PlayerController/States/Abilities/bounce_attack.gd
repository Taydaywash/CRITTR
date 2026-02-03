extends State

@export var icon : CompressedTexture2D

@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var ascending_state : State

@export_category("Parameters")
@export var bounce_velocity: float
@export var max_velocity: float
@export var bounce_input_buffer_patience: float

@export_category("References")
@export var up_area : Area2D
@export var down_area : Area2D
@export var right_area : Area2D
@export var left_area : Area2D


var direction: String
var bounce_input_buffer: Timer
var entered: bool
var gravity : float
var max_falling_speed : float
var horizontal_input : int = 0

func _ready() -> void:
	bounce_input_buffer = Timer.new()
	bounce_input_buffer.wait_time = bounce_input_buffer_patience
	bounce_input_buffer.one_shot = true
	add_child(bounce_input_buffer)

func set_direction(ability_direction : String) -> void:
	direction = ability_direction 

func activate(last_state : State) -> void:
	super(last_state)
	bounce_input_buffer.start()
	gravity = player.normal_gravity
	max_falling_speed = player.max_falling_speed
	match direction:
				"right":
					right_area.monitoring = true
					right_area.visible = true
				"left":
					left_area.monitoring = true
					left_area.visible = true
				"up":
					up_area.monitoring = true
					up_area.visible = true
				"down":
					down_area.monitoring = true
					down_area.visible = true
		

func process_input(_event : InputEvent) -> State:
	return null

func process_physics(delta) -> State:
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	#horizontal_input = int(Input.get_axis("move_left","move_right"))
	#if (abs(player.velocity.x) < air_control):
		#player.velocity.x += air_acceleration_speed * delta * horizontal_input
	#else:
		#player.velocity.x = player.velocity.move_toward(Vector2(0,0),air_decceleration_speed * delta).x
	#if horizontal_input == 0 or (sign(horizontal_input) != sign(player.velocity.x)):
		#player.velocity.x = player.velocity.move_toward(Vector2(0,0),air_decceleration_speed * delta).x
	player.move_and_slide()
	print(bounce_input_buffer.time_left)
	
	if (bounce_input_buffer.time_left == 0 or entered):
		print("Hello")
		return falling_state
	return null


func deactivate(_next_state : State) -> void:
	match direction:
				"right":
					right_area.monitoring = false
					right_area.visible = false
				"left":
					left_area.monitoring = false
					left_area.visible = false
				"up":
					up_area.monitoring = false
					up_area.visible = false
				"down":
					down_area.monitoring = false
					down_area.visible = false

func _on_area_2d_body_entered(_body):
	entered = true
	if (bounce_input_buffer.time_left != 0):
		match direction:
				"right":
					print("right")
				"left":
					print("left")
				"up":
					print("up")
				"down":
					print("down")

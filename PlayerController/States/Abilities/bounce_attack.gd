extends State

@export var icon : CompressedTexture2D

@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var walking_state : State 

@export_category("Parameters")
@export var max_velocity: float
@export var bounce_input_buffer_patience: float
@export var air_control : int
@export var air_acceleration_speed : int
@export var air_decceleration_speed : int

@export_category("References")
@export var up_area : Area2D
@export var down_area : Area2D
@export var right_area : Area2D
@export var left_area : Area2D


var direction: String
var bounce_input_buffer: Timer
var entered: bool
var gravity : float
var bounce_velocity : Vector2 = Vector2(2000,2000)
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
	entered = false
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
		
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(player.velocity.x) < air_control) or (sign(horizontal_input) != sign(player.velocity.x)):
		player.velocity.x += air_acceleration_speed * delta * horizontal_input
	if horizontal_input == 0:
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),air_decceleration_speed * delta).x 
	player.move_and_slide()
	
	if (bounce_input_buffer.time_left == 0 or entered):
		return falling_state
		
	if (player.is_on_floor() and bounce_input_buffer.time_left == 0):
		if abs(player.velocity.x) > 0:
			return walking_state
		else:
			return idle_state
		
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
	if (abs(player.velocity) > abs(bounce_velocity)):
		bounce_velocity = (abs(player.velocity))
	
	entered = true
	if (bounce_input_buffer.time_left != 0):
		match direction:
				"right":
					player.velocity.y += -750
					player.velocity.x = -bounce_velocity.x
					print("right")
				"left":
					player.velocity.y += -750
					player.velocity.x = bounce_velocity.x
					print("left")
				"up":
					player.velocity.y = bounce_velocity.y
					print("up")
				"down":
					player.velocity.y = -bounce_velocity.y
					print("down")

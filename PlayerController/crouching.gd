extends State

#States that Idle can transition to:
@export_category("States")
@export var idle_state : State
@export var walking_state : State
@export var falling_state : State
@export var jumping_state : State
@export var diving_state : State
@export var ability_state : State
@export_category("Parameters")
@export var sliding_deceleration : int
@export_category("Animations")
@export var y_initial_sprite_stretch_multiplier : float
@export var x_initial_sprite_stretch_multiplier : float
@export var sprite_reset_speed : float
@export var y_final_sprite_stretch_multiplier : float
@export var x_final_sprite_stretch_multiplier : float

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0
@onready var corner_nudging: Node2D = $"../../CornerNudging"

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	gravity = parent.normal_gravity
	max_falling_speed = parent.max_falling_speed
	sprite.scale.y = y_initial_sprite_stretch_multiplier
	sprite.scale.x = x_initial_sprite_stretch_multiplier

func process_input(_event : InputEvent) -> State:
	if !Input.is_action_pressed("move_down"):
		return can_uncrouch(idle_state)
	if Input.is_action_just_pressed("ability_up") or Input.is_action_just_pressed("ability_down") or Input.is_action_just_pressed("ability_left") or Input.is_action_just_pressed("ability_right"):
		return can_uncrouch(ability_state)
	if Input.is_action_just_pressed("jump") and parent.is_on_floor():
		return can_uncrouch(jumping_state)
	return null

func process_physics(delta) -> State:
	if parent.velocity.y < max_falling_speed:
		parent.velocity.y += gravity * delta
	parent.velocity.x = move_toward(parent.velocity.x,0,sliding_deceleration)
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return can_uncrouch(falling_state)
	return null

func process_frame(delta) -> State:
	sprite.scale.y = lerp(sprite.scale.y,y_final_sprite_stretch_multiplier,sprite_reset_speed * delta)
	sprite.scale.x = lerp(sprite.scale.x,x_final_sprite_stretch_multiplier,sprite_reset_speed * delta)
	return null

func can_uncrouch(intended_state) -> State:
	var uncrouch = true
	var arrays_hit = 0
	for ray in corner_nudging.get_children():
		if ray.is_colliding():
			arrays_hit += 1
		if arrays_hit >= 3:
			uncrouch = false
	if uncrouch:
		return intended_state
	return null

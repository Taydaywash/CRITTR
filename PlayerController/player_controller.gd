extends CharacterBody2D

#Movement
const walk_speed : int = 600
const jump_velocity : int = 1500
const max_fall_speed : int = 1500
const normal_gravity : int = 50
const bunny_hop_speed : float = 200
#Wall Jump
const wall_jump_vertical_velocity : float = 1500
const wall_jump_horizontal_velocity : float = 600
#Dive
const dive_horizontal_additive_velocity : float = 600
const dive_horizontal_default_velocity : float = 1000
const dive_vertical_velocity : float = 1000
const dive_bonk_horizontal_velocity : float = 500
const dive_bonk_vertical_velocity : float = 600
#Timers
const jump_input_buffer_patience : float = 0.2 #seconds
const coyote_time_patience : float = 0.5 #seconds
const bunny_hop_patience : float = 0.1 #seconds
const wall_jump_control_regain_delay : float = 0.5 #seconds
var jump_input_buffer : Timer
var coyote_time : Timer
var bunny_hop : Timer
var wall_jump_control_regain : Timer

var bunny_hops : int = 0
var coyote_jump_available : bool = true
var horizontal_input : float = 0
var jump_attempted : bool = false
var grounded : bool = true
var diving : bool = false
var has_bonked : bool = false

@onready var damage_hitbox: CollisionShape2D = $DamageHitbox
@onready var normal_hitbox: CollisionShape2D = $NormalHitbox
@onready var crouched_hitbox: CollisionShape2D = $CrouchedHitbox
@onready var player_sprite: Sprite2D = $PlayerSprite


func _ready() -> void:
	#Input buffer setup:
	jump_input_buffer = Timer.new()
	jump_input_buffer.wait_time = jump_input_buffer_patience
	jump_input_buffer.one_shot = true
	add_child(jump_input_buffer)
	
	#Coyote time setup:
	coyote_time = Timer.new()
	coyote_time.wait_time = coyote_time_patience
	coyote_time.one_shot = true
	add_child(coyote_time)
	
	#Bunny Hop timer setup:
	bunny_hop = Timer.new()
	bunny_hop.wait_time = bunny_hop_patience
	bunny_hop.one_shot = true
	add_child(bunny_hop)
	
	#Wall Jump Control Regain timer setup:
	wall_jump_control_regain = Timer.new()
	wall_jump_control_regain.wait_time = wall_jump_control_regain_delay
	wall_jump_control_regain.one_shot = true
	add_child(wall_jump_control_regain)

func _physics_process(_delta: float) -> void:
	if abs(velocity.x) < walk_speed:
		bunny_hops = 0
	if not diving:
		has_bonked = false
		horizontal_input = Input.get_axis("move_left","move_right")
		velocity.x = (walk_speed + (bunny_hop_speed * bunny_hops)) * horizontal_input 
	
#region Jumping Logic
	if Input.is_action_just_pressed("jump"):
		jump_input_buffer.start()
	if not Input.is_action_pressed("jump"): #Jump Variation
		if velocity.y < 100:
			velocity.y += normal_gravity * 3
	if is_on_floor():
		if grounded == false: # just landed
			bunny_hop.start()
		if bunny_hop.time_left == 0:
			bunny_hops = 0
		grounded = true
		coyote_jump_available = true
		diving = false
	else:
		if grounded == true: # Just left ground
			if coyote_jump_available == true:
				coyote_time.start()
		grounded = false
	if jump_input_buffer.time_left > 0: #Jumping
		if (grounded or coyote_time.time_left > 0):
			coyote_time.stop()
			jump_input_buffer.stop()
			coyote_jump_available = false
			velocity.y = -jump_velocity
			bunny_hops += 1
		elif (not grounded and is_on_wall()):
			velocity.x = wall_jump_horizontal_velocity * get_wall_normal().x
	if velocity.y < max_fall_speed and !grounded: #Apply Gravity
		velocity.y += normal_gravity
#endregion
	
#region Diving Logic
	if Input.is_action_just_pressed("dive") and !diving:
		coyote_time.stop()
		jump_input_buffer.stop()
		coyote_jump_available = false
		diving = true
		if abs(velocity.x) > dive_horizontal_default_velocity:
			velocity.x += dive_horizontal_additive_velocity * horizontal_input
		else:
			velocity.x = dive_horizontal_default_velocity * horizontal_input
		velocity.y = -dive_vertical_velocity
	if diving && is_on_wall():
		if has_bonked == false:
			velocity.x = -dive_bonk_horizontal_velocity * horizontal_input
			velocity.y = -dive_bonk_vertical_velocity
		has_bonked = true
#endregion
	
#region Crouching Logic
	#if Input.is_action_pressed("move_down"):
		#if grounded:
			#player_sprite.scale.x = lerp(scale.x, 44.0, 1)
			##player_sprite.scale.x = 44.0
			#player_sprite.scale.y = 22.0
			#crouched_hitbox.disabled = false
			#normal_hitbox.disabled = true
		#else:
			#if velocity.y > 0:
				#player_sprite.scale.y = 44.0
				#player_sprite.scale.x = 44.0 - velocity.y / 200
	#else:
		#player_sprite.scale.x = 44.0
		#player_sprite.scale.y = 44.0
		#crouched_hitbox.disabled = true
		#normal_hitbox.disabled = false
#endregion
	move_and_slide()

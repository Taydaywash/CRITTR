extends CharacterBody2D

#Movement
const walk_speed : int = 800
const jump_velocity : int = 1500
const max_fall_speed : int = 2000
const normal_gravity : int = 65
const bunny_hop_speed : int = 200
#Wall Jump
const wall_jump_vertical_velocity : int = 1200
const wall_jump_horizontal_velocity : int = 1000
const wall_cling_gravity : int = 10
var wall_cling : bool = false
var wall_on_left : bool = false
var wall_on_right : bool = false
var space_state : PhysicsDirectSpaceState2D
#Dive
const dive_horizontal_additive_velocity : int = 100
const dive_horizontal_default_velocity : int = 800
const dive_vertical_velocity : int = 800
const dive_bonk_horizontal_velocity : int = 500
const dive_bonk_vertical_velocity : int = 600
#Timers
const jump_input_buffer_patience : float = 0.2 #seconds
const coyote_time_patience : float = 0.5 #seconds
const bunny_hop_patience : float = 0.1 #seconds
const wall_jump_control_regain_delay : float = 0.3 #seconds
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
@onready var wall_jump_ray_reference: Node2D = $WallJumpRayReference

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
		if wall_jump_control_regain.time_left == 0:
			has_bonked = false
			horizontal_input = Input.get_axis("move_left","move_right")
			if horizontal_input != 0:
				velocity.x = (walk_speed + (bunny_hop_speed * bunny_hops)) * horizontal_input 
			else:
				bunny_hops = 0
				velocity.x = velocity.move_toward(Vector2(0,0),100).x
#region wall jump
	wall_on_right = _ray_hit(Vector2(65,0),1)
	wall_on_left = _ray_hit(Vector2(-65,0),1)
	wall_cling = is_on_wall() and velocity.y > 0 and (wall_on_left or wall_on_right) and !diving
#endregion
#region Jumping Logic
	if Input.is_action_just_pressed("jump"):
		jump_input_buffer.start()
	if not Input.is_action_pressed("jump") and not diving: #Jump Variation
		if velocity.y < 100:
			velocity.y += normal_gravity * 3
	if is_on_floor():
		if grounded == false: # just landed
			bunny_hop.start()
		if bunny_hop.time_left == 0:
			bunny_hops = 0
		wall_cling = false
		grounded = true
		coyote_jump_available = true
		diving = false
	else:
		if grounded == true: # Just left ground
			if coyote_jump_available == true:
				coyote_time.start()
		grounded = false
	if jump_input_buffer.time_left > 0 and !diving: #Jumping
		if (grounded or coyote_time.time_left > 0):
			coyote_time.stop()
			jump_input_buffer.stop()
			coyote_jump_available = false
			velocity.y = -jump_velocity
			bunny_hops += 1
		if (wall_on_right or wall_on_left) and velocity.y > 0:
			wall_jump_control_regain.start()
			velocity.y = -wall_jump_vertical_velocity
			if wall_on_right:
				velocity.x = -wall_jump_horizontal_velocity
			if wall_on_left:
				velocity.x = wall_jump_horizontal_velocity
	if velocity.y < max_fall_speed and !grounded: #Apply Gravity
		if wall_cling:
			velocity.y += wall_cling_gravity
		else:
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
		if grounded:
			velocity.x += dive_horizontal_additive_velocity * horizontal_input
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

func _ray_hit(direction : Vector2, layer_mask):
	space_state = get_world_2d().direct_space_state
	var short_ray = PhysicsRayQueryParameters2D.create(wall_jump_ray_reference.global_position, 
	wall_jump_ray_reference.global_position + direction, layer_mask)
	var result = space_state.intersect_ray(short_ray)
	if result:
		return true
	else:
		return false

func _on_hurtbox_body_entered(_body):
	print("entered")

func _on_crouched_hurtbox_body_entered(_body):
	print("entered")

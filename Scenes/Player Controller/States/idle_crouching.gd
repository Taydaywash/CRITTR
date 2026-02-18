extends State

#States that Idle can transition to:
@export_category("States")
@export var idle_state : State
@export var walking_state : State
@export var crouching_state : State
@export var falling_state : State
@export var jumping_state : State
@export var diving_state : State
@export var ability_state : State
@export_category("Colliders")
@export var default_hitbox : CollisionShape2D
@export var crouching_hitbox : CollisionShape2D
@export_category("Parameters")
@export var sliding_deceleration : int
@export var crouch_vertical_jump_speed : int
@export var crouch_horizontal_jump_speed : int
@export var crouched_walk_speed : int
@export var crouched_acceleration : int
@export_category("Corner Nudging Raycasts")
@export var nudge_right_range_left: RayCast2D
@export var nudge_right_range_right: RayCast2D
@export var nudge_left_range_right: RayCast2D
@export var nudge_left_range_left: RayCast2D
@export_category("Animations")
@export var y_initial_sprite_stretch_multiplier : float
@export var x_initial_sprite_stretch_multiplier : float
@export var sprite_reset_speed : float
@export var y_final_sprite_stretch_multiplier : float
@export var x_final_sprite_stretch_multiplier : float

var gravity : int
var max_falling_speed : int
var horizontal_input : int = 0

func activate(last_state : State) -> void:
	super(last_state) #Call activate as defined in state.gd and then also do:
	change_collider_to(crouching_hitbox)
	gravity = player.normal_gravity
	max_falling_speed = player.max_falling_speed
	if last_state != crouching_state:
		sprite.scale.y = y_initial_sprite_stretch_multiplier
		sprite.scale.x = x_initial_sprite_stretch_multiplier

func process_input(event : InputEvent) -> State:
	if event.is_action_pressed("jump") and player.is_on_floor() and can_uncrouch():
		return jumping_state
	if event.is_action_pressed("dive") and can_uncrouch():
		return diving_state
	if event.is_action_pressed("use_ability") and can_uncrouch():
		return ability_state
	return null

func process_physics(delta) -> State:
	if player.velocity.y < max_falling_speed:
		player.velocity.y += gravity * delta
	player.velocity.x = move_toward(player.velocity.x,0,sliding_deceleration)
	
	horizontal_input = int(Input.get_axis("move_left","move_right"))
	if (abs(player.velocity.x) < crouched_walk_speed) or (sign(horizontal_input) != sign(player.velocity.x)):
		player.velocity.x += crouched_acceleration * delta * horizontal_input
	if horizontal_input == 0:
		player.velocity.x = player.velocity.move_toward(Vector2(0,0),sliding_deceleration * delta).x
	player.move_and_slide()
	if abs(player.velocity.x) > 0:
		return crouching_state
	if !Input.is_action_pressed("move_down") and can_uncrouch():
		return idle_state
	if !player.is_on_floor() and can_uncrouch():
		return falling_state
	return null

func process_frame(delta) -> State:
	sprite.scale.y = lerp(sprite.scale.y,y_final_sprite_stretch_multiplier,sprite_reset_speed * delta)
	sprite.scale.x = lerp(sprite.scale.x,x_final_sprite_stretch_multiplier,sprite_reset_speed * delta)
	return null

func can_uncrouch() -> bool:
	var uncrouch = true
	if (nudge_right_range_left.is_colliding() or nudge_right_range_right.is_colliding() 
	or nudge_left_range_right.is_colliding() or nudge_left_range_left.is_colliding()):
		uncrouch = false
	return uncrouch

func deactivate(next_state) -> void:
	if next_state != crouching_state:
		super(next_state)
		change_collider_to(default_hitbox)

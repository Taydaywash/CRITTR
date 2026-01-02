extends State

@export var icon : CompressedTexture2D

@export_category("States")
@export var falling_state : State
@export var idle_state : State
@export var diving_state : State
@export var ascending_state : State

@export_category("Parameters")
var bounce_velocity: float
var max_velocity: float

@export_category("References")
@export var attack_hitbox: Area2D

var direction: String
var entered: bool

func set_direction(ability_direction : String) -> void:
	direction = ability_direction 

func activate(_last_state : State) -> void:
	match direction:
			"right":
				attack_hitbox.rotation = -90
			"left":
				attack_hitbox.rotation = 90
			"up":
				attack_hitbox.rotation = 180
			"down":
				pass
		

func process_input(_event : InputEvent) -> State:
	return null

func process_physics(_delta) -> State:
	return falling_state
	
	return null

func deactivate(_next_state : State) -> void:
	pass

func _on_area_2d_body_entered(body):
	if body is TileMapLayer:
		entered = true
		print("entered")

class_name door
extends interactable

@export var go_to_door : Node2D
var fade_player_out : bool = false

func _input(_event: InputEvent) -> void:
	if overlapping and can_interact():
		if Input.is_action_just_pressed("interact"):
			door_transition()

func door_transition() -> void:
	fade_player_out = true

func _process(delta: float) -> void:
	super(delta)
	if fade_player_out:
		player.modulate = lerp(player.modulate,Color(0.0,0.0,0.0,0.0), clampf(delta * 10,0.0,1.0))
		if player.modulate.a <= 0.1:
			fade_player_out = false
			player.modulate = Color(1.0,1.0,1.0,1.0)
			player.global_position = Vector2(go_to_door.global_position.x,go_to_door.global_position.y + 20)

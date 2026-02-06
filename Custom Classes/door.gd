class_name door
extends interactable

@export var go_to_door : Node2D

func _ready() -> void:
	super()
	
func _input(_event: InputEvent) -> void:
	if overlapping and can_interact():
		if Input.is_action_just_pressed("interact"):
			player.global_position = Vector2(go_to_door.global_position.x,go_to_door.global_position.y + 20)

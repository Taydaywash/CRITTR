class_name interactable
extends Area2D

@onready var player : Player = get_node("/root/World/Player")
const INTERACT_BUTTON_PROMPT = preload("uid://b5dx20wf4hqhj")
const INTERACTABLE_GLOW = preload("uid://bx70wgu6jkrdb")

var button_pronpt_instance : Sprite2D
var glow_instance : Sprite2D
var return_position : Vector2
var overlapping : bool

func _ready() -> void:
	button_pronpt_instance = Sprite2D.new()
	button_pronpt_instance.texture = INTERACT_BUTTON_PROMPT
	add_child(button_pronpt_instance)
	button_pronpt_instance.global_position = global_position
	button_pronpt_instance.modulate.a = 0.0
	return_position = global_position
	
	glow_instance = Sprite2D.new()
	glow_instance.texture = INTERACTABLE_GLOW
	add_child(glow_instance)
	glow_instance.global_position = global_position
	glow_instance.modulate.a = 0.0

func _process(delta: float) -> void:
	overlapping = overlaps_body(player)
	if overlapping:
		glow_instance.modulate.a = lerp(glow_instance.modulate.a,0.5,clampf(delta * 10, 0.0,1.0))
	else:
		glow_instance.modulate.a = lerp(glow_instance.modulate.a,0.0,clampf(delta * 2, 0.0,1.0))
	if overlapping and can_interact():
		button_pronpt_instance.modulate.a = lerp(button_pronpt_instance.modulate.a,1.0,clampf(delta * 10, 0.0,1.0))
		button_pronpt_instance.global_position = lerp(button_pronpt_instance.global_position, 
			return_position - Vector2(0,300), clampf(delta * 10, 0.0, 1.0))
	else:
		button_pronpt_instance.modulate.a = lerp(button_pronpt_instance.modulate.a,0.0,clampf(delta * 10, 0.0,1.0))
		button_pronpt_instance.global_position = lerp(button_pronpt_instance.global_position, 
			return_position, clampf(delta * 10, 0.0, 1.0))
func can_interact() -> bool:
	if abs(player.velocity.x + player.velocity.y) < 1:
		return true
	return false

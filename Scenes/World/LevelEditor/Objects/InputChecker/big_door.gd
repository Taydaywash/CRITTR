extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var close_trigger: Area2D = get_parent().get_node("DoorCloseTrigger")
@onready var passed_trigger: Area2D = get_parent().get_node("DoorPassedTrigger")
@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")

var is_open: bool = false

func _ready() -> void: 
	get_parent().get_node("InputChecker").sequence_matched.connect(matched)
	close_trigger.monitoring = false
	passed_trigger.monitoring = false
	
func matched() -> void:
	if not is_open:
		is_open = true
		camera.trigger_shake(10.0)
		passed_trigger.monitoring = true
		animation_player.play("open")
	
func close() -> void:
	if is_open: 
		is_open = false
		close_trigger.monitoring = false
		animation_player.play_backwards("open")

func _on_door_close_trigger_body_entered(body):
	if body is Player:
		close()

func _on_door_passed_trigger_body_entered(body):
	if body is Player:
		close_trigger.monitoring = true
		passed_trigger.monitoring = false

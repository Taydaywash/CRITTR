extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var close_trigger: Area2D = get_parent().get_node("DoorCloseTrigger")
@onready var passed_trigger: Area2D = get_parent().get_node("DoorPassedTrigger")
@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")

var is_open: bool = false

func _ready() -> void: 
	get_parent().get_node("InputChecker").sequence_matched.connect(matched)
	close_trigger.set_deferred("monitoring", false)
	passed_trigger.set_deferred("monitoring", false)
	
func matched() -> void:
	if not is_open:
		camera.trigger_shake(5.0)
		animation_player.play("open")
		await animation_player.animation_finished
		is_open = true
		passed_trigger.set_deferred("monitoring", true)
	
func close() -> void:
	if is_open: 
		camera.trigger_shake(5.0)
		animation_player.play_backwards("open")
		await animation_player.animation_finished
		is_open = false
		close_trigger.set_deferred("monitoring", false)

func _on_door_close_trigger_body_entered(body):
	print("closes")
	if body is Player:
		close()

func _on_door_passed_trigger_body_entered(body):
	print("passed")
	if body is Player:
		close_trigger.set_deferred("monitoring", true)
		passed_trigger.set_deferred("monitoring", false)


func _on_open_door_trigger_body_entered(_body: Node2D) -> void:
	matched()

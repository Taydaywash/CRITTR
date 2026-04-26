extends TileMapLayer

var door_opened : bool = false

@onready var animation_player: AnimationPlayer = $"../CPUParticles2D/AnimationPlayer"
@onready var audio_controller : AudioController = get_parent().get_parent().get_node("%AudioController")
@onready var big_dust: CPUParticles2D = $"../CPUParticles2D"
@onready var door_debris: CPUParticles2D = $"../CPUParticles2D2"
@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")
@onready var label: Label = $Label
@export var collectable_requirement : int = 18
const BIG_DOOR_OPEN_5_SEC = preload("uid://dbxa8yvvggc1g")

func _player_in_range(_body: Node2D) -> void:
	label.text = "%s/%s" % [GameController.game_state.total_collectables,collectable_requirement]
	if not GameController.game_state.total_collectables >= collectable_requirement:
		label.modulate = Color(1,0,0)
	else:
		label.modulate = Color(0,1,0)
	if not door_opened and GameController.game_state.total_collectables >= collectable_requirement:
		audio_controller.play_sound(BIG_DOOR_OPEN_5_SEC,1.0,1.0)
		door_opened = true
		camera.trigger_shake(5.0)
		animation_player.play("open")
		big_dust.emitting = true
		door_debris.emitting = true
		await animation_player.animation_finished
		big_dust.emitting = false
		door_debris.emitting = false
func _player_left_range(_body: Node2D) -> void:
	label.modulate = Color(1,1,1)

extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@warning_ignore("unused_signal")
signal start_crittr_turn
@warning_ignore("unused_signal")
signal start_player_turn

func _ready() -> void:
	pass
	#animation_player.play("enter_crittr_catcher")

func enter_crittr_catcher():
	animation_player.play("enter_crittr_catcher")
	emit_signal("start_player_turn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug Menu"):
		start_crittr_turn.emit()

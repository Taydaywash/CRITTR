extends Area2D
@export var ability_to_unlock : String
func _on_body_entered(_body: Node2D) -> void:
	EventController.emit_signal("unlock_ability",ability_to_unlock)

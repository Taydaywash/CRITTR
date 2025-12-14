extends Sprite2D

@onready var player_controller: CharacterBody2D = $".."
func _process(_delta: float) -> void:
	modulate = Color(1,1,1)
	if player_controller.velocity.x < 0:
		flip_h = true
	else:
		flip_h = false
	if player_controller.diving:
		if player_controller.velocity.x == 0:
			modulate = Color(0.2,0.2,0.2)
		elif not player_controller.has_bonked:
			modulate = Color(0,0,0)
		elif player_controller.has_bonked:
			modulate = Color(0.5,0.5,0.5)
		
	elif not player_controller.grounded:
		if player_controller.velocity.y < 0:
			modulate = Color(0,1,0)
		elif player_controller.velocity.y > 0:
			modulate = Color(1,0,0)
	elif abs(player_controller.velocity.x) > 0:
		modulate = Color(0,0.5,1)

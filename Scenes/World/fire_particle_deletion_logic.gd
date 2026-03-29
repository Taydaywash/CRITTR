extends CPUParticles2D

func _ready() -> void:
	for ability in GameController.abilities_unlocked:
		if GameController.abilities_unlocked[ability]:
			queue_free()
	EventController.connect("unlock_ability",func ability_unlocked(_ability):
		queue_free()
		)

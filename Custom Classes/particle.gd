class_name Particle
extends CPUParticles2D

@export var spawn_offset : Vector2

func play() -> void:
	position += spawn_offset
	emitting = true
	one_shot = true
	await finished
	queue_free()

@icon("res://Assets/Editor Icons/gear icon.png")
class_name ParticleController
extends Node

func spawn_particle(player : Player,particle : PackedScene,parent_to_player: bool = false):
	if SaveLoadManager.options.disabled_particles:
		return
	var particle_instance = particle.instantiate()
	particle_instance.player = player
	if parent_to_player:
		player.add_child(particle_instance)
	else:
		add_child(particle_instance)
	particle_instance.global_position = player.global_position
	particle_instance.play()

@icon("res://Assets/Editor Icons/Gear Icon.png")
extends AudioListener2D

@export var music_player : AudioStreamPlayer

func play_music(music : AudioStream):
	if music_player.stream != music:
		music_player.stream = music
		music_player.play()

func play_sound(sfx : AudioStream, min_pitch : float = 0.7, max_pitch : float = 1.3):
	if not sfx:
		return
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.stream = sfx
	sfx_player.pitch_scale = randf_range(min_pitch,max_pitch)
	sfx_player.play()
	await sfx_player.finished
	sfx_player.queue_free()

func change_master_volume_to(value: float):
	AudioServer.set_bus_volume_linear(0,value)
func change_music_volume_to(value: float):
	AudioServer.set_bus_volume_linear(1,value)
func change_sfx_volume_to(value: float):
	AudioServer.set_bus_volume_linear(2,value)

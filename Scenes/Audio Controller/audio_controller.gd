@icon("res://Assets/Editor Icons/Gear Icon.png")
class_name AudioController
extends AudioListener2D

@export var music_player : AudioStreamPlayer

func play_music(music : AudioStream):
	if music_player.stream != music:
		music_player.stream = music
		music_player.play()

func play_sound(sfx : AudioStream, min_pitch : float = 0.7, max_pitch : float = 1.3, sound_position := Vector2.ZERO):
	var sfx_player
	if not sfx:
		return
	if sound_position:
		sfx_player = AudioStreamPlayer2D.new()
	else:
		sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	if sound_position:
		sfx_player.volume_db = 1
		sfx_player.max_distance = 20000
		sfx_player.attenuation = 0.4
		sfx_player.global_position = sound_position
	sfx_player.bus = "SFX"
	sfx_player.stream = sfx
	sfx_player.pitch_scale = randf_range(min_pitch,max_pitch)
	sfx_player.play()
	await sfx_player.finished
	sfx_player.queue_free()

func enable_low_pass():
	AudioServer.set_bus_effect_enabled(1,0,true)
func disable_low_pass():
	AudioServer.set_bus_effect_enabled(1,0,false)

func change_master_volume_to(value: float):
	AudioServer.set_bus_volume_linear(0,value)
func change_music_volume_to(value: float):
	AudioServer.set_bus_volume_linear(1,value)
func change_sfx_volume_to(value: float):
	AudioServer.set_bus_volume_linear(2,value)

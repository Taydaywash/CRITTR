extends AudioListener2D

@export var music_player : AudioStreamPlayer

func play_music(music : AudioStream):
	music_player.stream = music
	music_player.play()

func play_sound(sfx : AudioStream):
	if not sfx:
		return
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.stream = sfx
	sfx_player.play()
	await sfx_player.finished
	sfx_player.queue_free()

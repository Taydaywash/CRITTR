extends AudioListener2D

@export var music_player : AudioStreamPlayer

func play_music(music : Resource):
	music_player.stream = music
	music_player.play()

func play_sound(sfx : Resource):
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.stream = sfx
	sfx_player.play()
	await sfx_player.finished
	print("added sound")
	sfx_player.queue_free()
	print("deleted sound")

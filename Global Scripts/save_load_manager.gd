extends Node

const options_save_path = "user://options.save"

var ability_up : State
var ability_down : State
var ability_left : State
var ability_right : State

var ability_wheel = {
	"ability_up": ability_up, 
	"ability_down": ability_down, 
	"ability_left": ability_left,
	"ability_right": ability_right }

var options : Dictionary = {
	"screen_size": DisplayServer.WINDOW_MODE_WINDOWED,
	"on_top" : false,
	"master_volume": 50,
	"music_volume": 50,
	"sfx_volume": 50,
	"screen_resolution" : Vector2(1152, 648),
	"text_speed" : 0.4,
	"disabled_particles" : false,
}

func save_options(options_copy):
	options = options_copy.duplicate()
	var file = FileAccess.open(options_save_path, FileAccess.WRITE)
	file.store_var(options.duplicate())
	file.close()

func load_options() -> Dictionary:
	if FileAccess.file_exists(options_save_path):
		var file = FileAccess.open(options_save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		options = data.duplicate()
	return options.duplicate()

extends Node

const OPTIONS_SAVE_PATH = "user://options.save"
const GAME_SAVE_PATH = "user://game.save"

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
	var file = FileAccess.open(OPTIONS_SAVE_PATH, FileAccess.WRITE)
	file.store_var(options.duplicate())
	file.close()

func load_options() -> Dictionary:
	if FileAccess.file_exists(OPTIONS_SAVE_PATH):
		var file = FileAccess.open(OPTIONS_SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		options = data.duplicate()
	return options.duplicate()

func save_game(collected_ids: Dictionary, total: int):
	var data: Dictionary = {
		"collected_ids": collected_ids,
		"total_collectables": total
	}
	var file = FileAccess.open(GAME_SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	
func load_game() -> Dictionary:
	if FileAccess.file_exists(GAME_SAVE_PATH):
		var file = FileAccess.open(GAME_SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		return data.duplicate(true)
	return {"collected_ids": {}, "total_collectables": 0}
	
func reset_game():
	if FileAccess.file_exists(GAME_SAVE_PATH):
		DirAccess.remove_absolute(GAME_SAVE_PATH)

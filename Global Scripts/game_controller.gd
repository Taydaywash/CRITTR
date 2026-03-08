extends Node

var ability_usages: int = 2
var abilities_unlocked: Dictionary = {
	"dash" : true,
	"grapple" : false,
	"climb" : false,
	"inflate" : false,
	"drill" : false,
	"bounce" : false,
}

var BASE_GAME_STATE : Dictionary = {
	"collected_ids": {},
	"viewed_tutorial_text": {},
	"explored_rooms": {},
	"current_abilities": [],
	"abilities_unlocked": abilities_unlocked.duplicate(),
	"last_respawn_point": Vector2.ZERO,
	"total_collectables": 0
}

var game_state : Dictionary = BASE_GAME_STATE.duplicate(true)

func _ready():
	restore_state()
	EventController.connect("save_and_quit",func save_and_quit_data(data):
		game_state.last_respawn_point = data.last_respawn_point
		SaveLoadManager.save_game(game_state)
		)
	EventController.connect("tutorial_text_viewed",func add_tutorial_text_viewed(id):
		game_state.viewed_tutorial_text[id] = null
		SaveLoadManager.save_game(game_state)
		)
	EventController.connect("update_current_abilities",func update_current_abilities(abilities):
		game_state.current_abilities = abilities
		SaveLoadManager.save_game(game_state)
		)
	EventController.connect("collectable_collected",collectable_collected)
	EventController.connect("room_explored",func room_explored(room_id):
		game_state.explored_rooms[room_id] = null #way of making a set using dict
		SaveLoadManager.save_game(game_state)
		)
	reset_game()

func collectable_collected(id: String, value: int) -> void:
	if game_state.collected_ids.has(id):
		return
	game_state.collected_ids[id] = true
	game_state.total_collectables += value
	print("Total collected: ", game_state.total_collectables)
	SaveLoadManager.save_game(game_state)
	
func is_collected(id: String) -> bool:
	return game_state.collected_ids.has(id)
func get_abilities_unlocked() -> Dictionary:
	return game_state.abilities_unlocked.duplicate()
func get_current_abilities() -> Array:
	return game_state.current_abilities.duplicate(true)
func restore_state():
	game_state = SaveLoadManager.load_game()
func reset_game():
	game_state = BASE_GAME_STATE
	#SaveLoadManager.reset_game()

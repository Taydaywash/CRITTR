extends Node

var ability_usages: int = 2
var abilities_unlocked: Dictionary = {
	"dash" : true,
	"grapple" : true,
	"climb" : true,
	"inflate" : true,
	"drill" : false,
	"bounce" : false,
}

var BASE_GAME_STATE : Dictionary = {
	"collected_ids": {},
	"total_collectables": 0
}

var game_state : Dictionary = BASE_GAME_STATE.duplicate(true)

func _ready():
	restore_state()
	reset_game()

func collectable_collected(id: String, value: int) -> void:
	if game_state.collected_ids.has(id):
		return
	game_state.collected_ids[id] = true
	game_state.total_collectables += value
	EventController.emit_signal("collectable_collected", game_state.total_collectables)
	SaveLoadManager.save_game(game_state)
	
func is_collected(id: String) -> bool:
	return game_state.collected_ids.has(id)
func get_abilities_unlocked() -> Dictionary:
	return abilities_unlocked.duplicate()
func restore_state():
	game_state = SaveLoadManager.load_game()

func reset_game():
	game_state = BASE_GAME_STATE
	#SaveLoadManager.reset_game()

extends Node

var ability_usages: int = 2
var abilities_unlocked: Dictionary = {
	"dash" : true,
	"grapple" : true,
	"climb" : false,
	"inflate" : false,
	"drill" : false,
	"bounce" : false,
}
var total_collectables: int = 0
var collected_ids: Dictionary = {}

func _ready():
	restore_state()
	reset_game()

func collectable_collected(id: String, value: int) -> void:
	if collected_ids.has(id):
		return
	collected_ids[id] = true
	total_collectables += value
	EventController.emit_signal("collectable_collected", total_collectables)
	SaveLoadManager.save_game(collected_ids, total_collectables)
	
func is_collected(id: String) -> bool:
	return collected_ids.has(id)
func get_abilities_unlocked() -> Dictionary:
	return abilities_unlocked.duplicate()
func restore_state():
	var data = SaveLoadManager.load_game()
	collected_ids = data["collected_ids"]
	total_collectables = data["total_collectables"]

func reset_game():
	collected_ids.clear()
	total_collectables = 0
	SaveLoadManager.reset_game()

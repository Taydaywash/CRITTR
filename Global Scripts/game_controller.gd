extends Node

var total_collectables: int = 0

func collectable_collected(value: int):
	total_collectables += value
	EventController.emit_signal("collectable_collected", total_collectables)

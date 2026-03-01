extends Node

@warning_ignore("unused_signal")
signal collectable_collected(total: int)

func _ready():
	collectable_collected.connect(_on_collectable_collected)

func _on_collectable_collected(total: int):
	print("Total collected: ", total)

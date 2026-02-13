extends Control

const WORLD = preload("res://World/World.tscn")

func _ready() -> void:
	get_tree().paused = false

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD)

func _on_setting_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()

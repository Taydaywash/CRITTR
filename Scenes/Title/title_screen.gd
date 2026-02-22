extends Control

const WORLD = preload("res://Scenes/World/World.tscn")
@export var options_tab : Panel
@export var options_tab_back : Panel
@export var audio_controller : AudioController

func _ready() -> void:
	get_tree().paused = false

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD)

func _on_setting_button_pressed() -> void:
	options_tab.visible = true
	options_tab.options_opened()
	options_tab_back.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	options_tab.visible = false
	options_tab.options_closed()
	options_tab_back.visible = false

extends Control

const WORLD = preload("res://Scenes/World/World.tscn")
@export var play_button : Button
@export var options_tab : Panel
@export var options_tab_back : Panel
@export var audio_controller : AudioController

const UI_HOVER = preload("uid://bvfiha76ltfmi")
const UI_CANCEL = preload("uid://ejjyhdoxq4xd")
const UI_CONFIRM = preload("uid://c3jo2nkgwvncg")


func _ready() -> void:
	$PlayButton.grab_focus()
	get_tree().paused = false

func _on_play_button_pressed() -> void:
	audio_controller.play_sound(UI_CONFIRM)
	get_tree().change_scene_to_packed(WORLD)

func _on_setting_button_pressed() -> void:
	audio_controller.play_sound(UI_CONFIRM)
	options_tab.visible = true
	options_tab.options_opened()
	options_tab.default_focus.grab_focus()
	options_tab_back.visible = true

func _on_quit_button_pressed() -> void:
	audio_controller.play_sound(UI_CONFIRM)
	get_tree().quit()

func _on_back_pressed() -> void:
	audio_controller.play_sound(UI_CANCEL)
	options_tab.visible = false
	options_tab.options_closed()
	play_button.grab_focus()
	options_tab_back.visible = false


func _on_reset_game_state_pressed() -> void:
	audio_controller.play_sound(UI_CANCEL)
	GameController.reset_game()

func _on_back_mouse_entered() -> void:
	audio_controller.play_sound(UI_HOVER)
func _on_play_button_focus_entered() -> void:
	audio_controller.play_sound(UI_HOVER)
func _on_reset_game_state_focus_entered() -> void:
	audio_controller.play_sound(UI_HOVER)
func _on_setting_button_focus_entered() -> void:
	audio_controller.play_sound(UI_HOVER)
func _on_quit_button_focus_entered() -> void:
	audio_controller.play_sound(UI_HOVER)

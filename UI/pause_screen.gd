extends CanvasLayer

var paused = true

@export var dna_button : Button
@export var resume_button : Button
@export var dna_tab : Panel
@export var map_tab : Panel
@export var map : Node2D
@export var options_tab : Panel
@export var stuff_tab : Panel

func _ready() -> void:
	toggle_pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		dna_button.grab_focus()
		show_layer(dna_tab)

func toggle_pause() -> void:
	paused = !paused
	visible = paused
	get_tree().paused = paused

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_setting_button_pressed() -> void:
	pass # Replace with function body.

func _on_main_menu_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file("res://Title/TitleScreen.tscn")


func _on_dna_button_pressed() -> void:
	show_layer(dna_tab)

func _on_map_button_pressed() -> void:
	show_layer(map_tab)

func _on_options_button_pressed() -> void:
	show_layer(options_tab)
	resume_button.grab_focus()

func _on_stuff_button_pressed() -> void:
	show_layer(stuff_tab)

func show_layer(layer : Panel):
	dna_tab.visible = false
	map_tab.visible = false
	options_tab.visible = false
	stuff_tab.visible = false
	
	layer.visible = true
	map.show_map(map_tab.visible)

extends CanvasLayer
@export var audio_controller : AudioListener2D
@export_category("Tab Buttons")
@export var dna_button : Button
@export var map_button : Button
@export var options_button : Button
@export var stuff_button : Button
@export_category("Tabs")
@export var dna_tab : Panel
@export var dna_tab_blocker : Panel
@export var map_tab : Panel
@export var map : Node2D
@export var options_tab : Panel
@export var stuff_tab : Panel
var paused = true
var current_tab : Panel
var used_save_point: bool = false

func _ready() -> void:
	toggle_pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	if event.is_action_released("ui_cancel"):
		if dna_button.has_focus() or map_button.has_focus() or options_button.has_focus() or stuff_button.has_focus():
			toggle_pause()
	current_tab.handle_input(event)

func toggle_pause(from_save_point : bool = false) -> void:
	used_save_point = false
	if from_save_point:
		used_save_point = true
		
	dna_button.grab_focus()
	show_layer(dna_tab)
	dna_tab_blocker.visible = !used_save_point
	
	paused = !paused
	visible = paused
	get_tree().paused = paused
	
func _on_dna_button_focus_entered() -> void:
	show_layer(dna_tab)
	dna_tab.update_ability_icons()
func _on_map_button_pressed() -> void:
	show_layer(map_tab)
func _on_options_button_pressed() -> void:
	show_layer(options_tab)
func _on_stuff_button_pressed() -> void:
	show_layer(stuff_tab)

func show_layer(tab : Panel):
	dna_tab.visible = false
	map_tab.visible = false
	options_tab.visible = false
	stuff_tab.visible = false
	
	tab.visible = true
	current_tab = tab
	map.show_map(map_tab.visible)

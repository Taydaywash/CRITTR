extends CanvasLayer

var paused = true

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
@export_category("Tab Initial Focuses")
@export var dash_button : Button
@export var resume_button : Button
@export var map_focus : Button

var current_tab : Panel
var used_save_point: bool = false

func _ready() -> void:
	toggle_pause()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_released("ui_cancel"):
		if dna_button.has_focus() or map_button.has_focus() or options_button.has_focus() or stuff_button.has_focus():
			toggle_pause()
		if current_tab == dna_tab:
			dna_button.grab_focus()
		if current_tab == map_tab:
			map_button.grab_focus()
		if current_tab == options_tab:
			options_button.grab_focus()
	if Input.is_action_just_released("ui_accept"):
		if current_tab == dna_tab and dna_button.has_focus():
			dash_button.grab_focus()
		if current_tab == map_tab:
			map_focus.grab_focus()
		if current_tab == options_tab:
			resume_button.grab_focus()

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

func _process(_delta: float) -> void:
	if map_focus.has_focus():
		if Input.is_action_pressed("move_up"):
			map.camera.position.y -= map.camera_move_speed
		if Input.is_action_pressed("move_down"):
			map.camera.position.y += map.camera_move_speed
		if Input.is_action_pressed("move_left"):
			map.camera.position.x -= map.camera_move_speed
		if Input.is_action_pressed("move_right"):
			map.camera.position.x += map.camera_move_speed

func _on_dash_focus_entered() -> void:
	if not used_save_point:
		dna_button.grab_focus()

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
@export var dna_initial_focus : Button
@export var options_initial_focus : Button
@export var map_initial_focus : Button

@export_category("Abilities")
@export var up_ability : Button
@export var down_ability : Button
@export var left_ability : Button
@export var right_ability : Button
@onready var abilities: AbilityController = get_node("/root/World/Player/StateMachine/Abilities")

var current_tab : Panel
var used_save_point: bool = false
var held_ability : State

func _ready() -> void:
	toggle_pause()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_released("ui_cancel"):
		if up_ability.has_focus() or down_ability.has_focus() or left_ability.has_focus() or right_ability.has_focus():
			dna_initial_focus.grab_focus()
		elif dna_button.has_focus() or map_button.has_focus() or options_button.has_focus() or stuff_button.has_focus():
			toggle_pause()
		if current_tab == dna_tab:
			dna_button.grab_focus()
		if current_tab == map_tab:
			map_button.grab_focus()
		if current_tab == options_tab:
			options_button.grab_focus()
	if Input.is_action_just_released("ui_accept"):
		if current_tab == dna_tab and dna_button.has_focus():
			dna_initial_focus.grab_focus()
		if current_tab == map_tab:
			map_initial_focus.grab_focus()
		if current_tab == options_tab:
			options_initial_focus.grab_focus()

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

#DNA
#region DNA TAB
func _on_dna_button_pressed() -> void:
	show_layer(dna_tab)
	update_ability_icons()
func update_ability_icons() -> void:
	up_ability.icon = abilities.abilities_in_use.ability_up.texture
	down_ability.icon = abilities.abilities_in_use.ability_down.texture
	left_ability.icon = abilities.abilities_in_use.ability_left.texture
	right_ability.icon = abilities.abilities_in_use.ability_right.texture
func _on_dash_focus_entered() -> void:
	if not used_save_point:
		dna_button.grab_focus()
func _on_dash_pressed() -> void:
	ability_pressed(index_to_ability(0))
func _on_grapple_pressed() -> void:
	ability_pressed(index_to_ability(1))
func _on_climb_pressed() -> void:
	ability_pressed(index_to_ability(2))
func _on_inflate_pressed() -> void:
	ability_pressed(index_to_ability(3))
func _on_drill_pressed() -> void:
	ability_pressed(index_to_ability(4))
func _on_bounce_pressed() -> void:
	ability_pressed(index_to_ability(5))
func index_to_ability(index):
	if index == 0:
		return abilities.dashing_state
	if index == 1:
		return abilities.grappling_state
	if index == 2:
		return abilities.climbing_state
	if index == 3:
		return abilities.inflated_state
	if index == 4:
		return abilities.drill_state
	if index == 5:
		return abilities.bounce_attack_state
func ability_pressed(ability : State):
	held_ability = ability
	up_ability.grab_focus()

func _on_up_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("up",held_ability)
	dna_initial_focus.grab_focus()
	update_ability_icons()
	held_ability = null
func _on_down_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("down",held_ability)
	dna_initial_focus.grab_focus()
	update_ability_icons()
	held_ability = null
func _on_left_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("left",held_ability)
	dna_initial_focus.grab_focus()
	update_ability_icons()
	held_ability = null
func _on_right_pressed() -> void:
	if not held_ability:
		return
	abilities.set_ability("right",held_ability)
	dna_initial_focus.grab_focus()
	update_ability_icons()
	held_ability = null
#endregion
#MAP
#region MAP TAB
func _on_map_button_pressed() -> void:
	show_layer(map_tab)
func _process(_delta: float) -> void:
	if map_initial_focus.has_focus():
		if Input.is_action_pressed("move_up"):
			map.camera.position.y -= map.camera_move_speed
		if Input.is_action_pressed("move_down"):
			map.camera.position.y += map.camera_move_speed
		if Input.is_action_pressed("move_left"):
			map.camera.position.x -= map.camera_move_speed
		if Input.is_action_pressed("move_right"):
			map.camera.position.x += map.camera_move_speed
#endregion
#OPTIONS
#region OPTIONS TAB
func _on_options_button_pressed() -> void:
	show_layer(options_tab)
func _on_setting_button_pressed() -> void:
	pass # Replace with function body.
func _on_main_menu_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file("res://Title/TitleScreen.tscn")
#endregion
#STUFF
#region STUFF TAB
func _on_stuff_button_pressed() -> void:
	show_layer(stuff_tab)
#endregion

func show_layer(tab : Panel):
	dna_tab.visible = false
	map_tab.visible = false
	options_tab.visible = false
	stuff_tab.visible = false
	
	tab.visible = true
	current_tab = tab
	map.show_map(map_tab.visible)

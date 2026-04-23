extends CanvasLayer
@export var audio_controller : AudioListener2D
@export var animation_player : AnimationPlayer
@export var player_reference : Player
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
@onready var ui: UI = %UI

var paused = false
var current_tab : Panel
var used_save_point: bool = false
var game_loaded : bool = false #Work around to fix big when pausing before scene is fully loaded

func _ready() -> void:
	#toggle_pause()
	await get_tree().create_timer(1).timeout
	game_loaded = true

func can_pause() -> bool:
	if not game_loaded:
		return false
	if get_tree().paused and not paused:
		return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	#if not player_reference.is_on_floor():
		#return
	if ui.screen_overlay.modulate.a != 0.0:
		return
	if animation_player.is_playing():
		return
	if not can_pause():
		return
	if event.is_action_pressed("pause"):
		if not ui.choicer_dialog.visible:
			toggle_pause()
			return
	if event.is_action_pressed("quick_map"):
		if not ui.choicer_dialog.visible:
			toggle_pause(false, "map")
			return
	if event.is_action_released("ui_cancel") and paused:
		if dna_button.has_focus() or map_button.has_focus() or options_button.has_focus() or stuff_button.has_focus():
			toggle_pause()
			return
	if not current_tab:
		return
	current_tab.handle_input(event)

func toggle_pause(from_save_point : bool = false, starting_tab : String = "dna") -> void:
	used_save_point = false
	if from_save_point:
		used_save_point = true
	paused = !paused
	if paused:
		audio_controller.enable_low_pass()
		visible = true
		animation_player.play("open_pause_menu")
	else:
		animation_player.play("close_pause_menu")
		
	if paused:
		match starting_tab:
			"dna":
				dna_button.grab_focus()
				show_layer(dna_tab)
			"map":
				map_tab.default_focus.grab_focus()
				show_layer(map_tab)
	dna_tab_blocker.visible = !used_save_point

	get_tree().paused = paused
	if not paused:
		audio_controller.disable_low_pass()
		await animation_player.animation_finished
		dna_button.grab_focus()
		show_layer(dna_tab)
func _on_dna_button_focus_entered() -> void:
	show_layer(dna_tab)
	dna_tab.dna_tab_opened()
func _on_map_button_pressed() -> void:
	show_layer(map_tab)
func _on_options_button_pressed() -> void:
	show_layer(options_tab)
	options_tab.options_opened()
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

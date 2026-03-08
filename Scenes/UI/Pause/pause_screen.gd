extends CanvasLayer
@export var audio_controller : AudioListener2D
@export var animation_player : AnimationPlayer
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
var paused = false
var current_tab : Panel
var used_save_point: bool = false
var can_pause : bool = false #Work around to fix big when pausing before scene is fully loaded

func _ready() -> void:
	#toggle_pause()
	await get_tree().create_timer(0.1).timeout
	can_pause = true

func _input(event: InputEvent) -> void:
	if animation_player.is_playing():
		return
	if not can_pause:
		return
	if event.is_action_pressed("pause"):
		toggle_pause(false)
		return
	if event.is_action_pressed("quick_map"):
		toggle_pause(false, "map")
		return
	if event.is_action_released("ui_cancel"):
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
		match starting_tab:
			"dna":
				dna_button.grab_focus()
				show_layer(dna_tab)
			"map":
				map_tab.default_focus.grab_focus()
				show_layer(map_tab)
	dna_tab_blocker.visible = !used_save_point
	if paused:
		animation_player.play("open_pause_menu")
	else:
		animation_player.play("close_pause_menu")
	get_tree().paused = paused
	if not paused:
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

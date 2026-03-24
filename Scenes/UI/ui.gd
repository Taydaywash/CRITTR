class_name UI
extends CanvasLayer

@onready var audio_controller = %AudioController
@onready var abilitiy_wheel: Panel = $AbilitiyWheel
@onready var screen_overlay: Panel = %ScreenOverlay
@onready var choicer_dialog: Panel = %TextBoxChoicer
@onready var text_popup: Panel = %TextPopup

func _process(_delta: float) -> void:
	if get_tree().paused:
		abilitiy_wheel.visible = false
	else:
		abilitiy_wheel.visible = true

func update_ability_ui(abilities_in_use : Dictionary):
	$AbilitiyWheel/Panel.texture = abilities_in_use.ability_up.texture
	$AbilitiyWheel/Panel2.texture = abilities_in_use.ability_left.texture
	$AbilitiyWheel/Panel3.texture = abilities_in_use.ability_down.texture
	$AbilitiyWheel/Panel4.texture = abilities_in_use.ability_right.texture
	
	$AbilitiyWheel/Panel.visible = abilities_in_use.ability_up.available
	$AbilitiyWheel/Panel2.visible = abilities_in_use.ability_left.available
	$AbilitiyWheel/Panel3.visible = abilities_in_use.ability_down.available
	$AbilitiyWheel/Panel4.visible = abilities_in_use.ability_right.available

func set_fade(alpha : float):
	screen_overlay.modulate.a = alpha

func increment_fade_in(delta : float, screen_fade_speed : float):
	screen_overlay.modulate.a = lerp(screen_overlay.modulate.a,1.0,clampf(delta * screen_fade_speed, 0.0, 1.0))
	if screen_overlay.modulate.a >= 0.99:
		screen_overlay.modulate.a = 1.0

func screen_is_black():
	@warning_ignore("shadowed_variable")
	var screen_is_black : bool = false
	if screen_overlay.modulate.a == 1.0:
		screen_is_black = true
	return screen_is_black

func increment_fade_out(delta : float, screen_fade_speed : float):
	screen_overlay.modulate.a = lerp(screen_overlay.modulate.a,0.0,clampf(delta * screen_fade_speed, 0.0, 1.0))
	if screen_overlay.modulate.a <= 0.01:
		screen_overlay.modulate.a = 0.0

func screen_is_clear():
	@warning_ignore("shadowed_variable")
	var screen_is_black : bool = false
	if screen_overlay.modulate.a == 0.0:
		screen_is_black = true
	return screen_is_black

func start_typing_choicer_text(dialog : String,choicer_handler : ChoicerHandler) -> void:
	choicer_dialog.start_typing_text(dialog,choicer_handler)
func reset_choicer_text() -> void:
	choicer_dialog.reset_text()

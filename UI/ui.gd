extends CanvasLayer

@onready var screen_overlay: Panel = $ScreenOverlay

func update_ability_ui(abilities_in_use : Dictionary):
	$Panel/Panel.visible = abilities_in_use.ability_up.available
	$Panel/Panel2.visible = abilities_in_use.ability_left.available
	$Panel/Panel3.visible = abilities_in_use.ability_down.available
	$Panel/Panel4.visible = abilities_in_use.ability_right.available

func set_fade(alpha : float):
	screen_overlay.modulate.a = alpha

func increment_fade_in(delta : float, screen_fade_speed : float):
	screen_overlay.modulate.a = lerp(screen_overlay.modulate.a,1.0,delta * screen_fade_speed)
	if screen_overlay.modulate.a >= 0.99:
		screen_overlay.modulate.a = 1.0

func is_fading_in():
	var still_fading : bool = true
	if screen_overlay.modulate.a == 1.0:
		still_fading = false
	return still_fading

func increment_fade_out(delta : float, screen_fade_speed : float):
	screen_overlay.modulate.a = lerp(screen_overlay.modulate.a,0.0,delta * screen_fade_speed)
	if screen_overlay.modulate.a <= 0.01:
		screen_overlay.modulate.a = 0.0

func is_fading_out():
	var still_fading : bool = true
	if screen_overlay.modulate.a == 0.00:
		still_fading = false
	return still_fading

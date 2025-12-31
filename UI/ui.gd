class_name UI
extends CanvasLayer

@onready var screen_overlay: Panel = $ScreenOverlay

func update_ability_ui(abilities_in_use : Dictionary):
	$Panel/Panel.texture = abilities_in_use.ability_up.texture
	$Panel/Panel2.texture = abilities_in_use.ability_left.texture
	$Panel/Panel3.texture = abilities_in_use.ability_down.texture
	$Panel/Panel4.texture = abilities_in_use.ability_right.texture
	
	$Panel/Panel.visible = abilities_in_use.ability_up.available
	$Panel/Panel2.visible = abilities_in_use.ability_left.available
	$Panel/Panel3.visible = abilities_in_use.ability_down.available
	$Panel/Panel4.visible = abilities_in_use.ability_right.available

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

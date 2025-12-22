extends CanvasLayer
@onready var screen_overlay: Panel = $ScreenOverlay

func update_ability_ui(abilities_in_use : Dictionary):
	$Panel/Panel.visible = abilities_in_use.ability_up.available
	$Panel/Panel2.visible = abilities_in_use.ability_left.available
	$Panel/Panel3.visible = abilities_in_use.ability_down.available
	$Panel/Panel4.visible = abilities_in_use.ability_right.available

func set_fade(alpha : float):
	screen_overlay.modulate.a = alpha

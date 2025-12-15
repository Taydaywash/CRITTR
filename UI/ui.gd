extends CanvasLayer

func update_ability_ui(abilities_in_use : Dictionary):
	$Panel/Panel.visible = abilities_in_use.ability_up.available
	$Panel/Panel2.visible = abilities_in_use.ability_left.available
	$Panel/Panel3.visible = abilities_in_use.ability_down.available
	$Panel/Panel4.visible = abilities_in_use.ability_right.available

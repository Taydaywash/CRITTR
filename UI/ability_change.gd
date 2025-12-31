extends CanvasLayer

@onready var abilities: AbilityController = $"../Player/StateMachine/Abilities"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Ability Select Menu"):
		visible = !visible

func _on_back_pressed() -> void:
	visible = false

func _on_up_item_selected(index: int) -> void:
	abilities.set_ability("up",index_to_ability(index))

func _on_down_item_selected(index: int) -> void:
	abilities.set_ability("down",index_to_ability(index))

func _on_left_item_selected(index: int) -> void:
	abilities.set_ability("left",index_to_ability(index))

func _on_right_item_selected(index: int) -> void:
	abilities.set_ability("right",index_to_ability(index))

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

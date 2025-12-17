extends State

@export var dashing_state : State
@export var grappling_state : State
@export var climbing_state : State
@export var infated_state : State
@export var bounce_attack_state : State
@export var drill_state : State
@export_category("")
@export var ability_up : State
@export var ability_down : State
@export var ability_left : State
@export var ability_right : State

@onready var ui: CanvasLayer = $"../../../UI"
@onready var abilities_in_use: Dictionary = {
	"ability_up": {
		"state" : ability_up, 
		"available" : true,
		"direction" : "up",
		"priority": 0 #used to determine which move to use based on most recent direction pressed
		},
	"ability_down": {
		"state" : ability_down, 
		"available" : true,
		"direction" : "down",
		"priority": 0 #used to determine which move to use based on most recent direction pressed
		},
	"ability_left": {
		"state" : ability_left, 
		"available" : true,
		"direction" : "left",
		"priority": 0 #used to determine which move to use based on most recent direction pressed
		},
	"ability_right": {
		"state" : ability_right, 
		"available" : true,
		"direction" : "right",
		"priority": 0 #used to determine which move to use based on most recent direction pressed
		},
	}

func is_ability_input(_event: InputEvent,_last_directional_input: String):
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up"):
		increment_priority("ability_up", 1)
	elif Input.is_action_just_pressed("move_down"):
		increment_priority("ability_down", 1)
	elif Input.is_action_just_pressed("move_left"):
		increment_priority("ability_left", 1)
	elif Input.is_action_just_pressed("move_right"):
		increment_priority("ability_right", 1)
	elif Input.is_action_just_released("move_up"):
		increment_priority("ability_up", -1)
	elif Input.is_action_just_released("move_down"):
		increment_priority("ability_down", -1)
	elif Input.is_action_just_released("move_left"):
		increment_priority("ability_left", -1)
	elif Input.is_action_just_released("move_right"):
		increment_priority("ability_right", -1)

func increment_priority(ability_direction_name : String, increment : int):
	if increment < 0:
		for ability in abilities_in_use:
			if abilities_in_use[ability]["priority"] > abilities_in_use[ability_direction_name]["priority"]:
				abilities_in_use[ability]["priority"] += increment
		abilities_in_use[ability_direction_name]["priority"] = 0
	else:
		for ability in abilities_in_use:
			if ((abilities_in_use[ability]["priority"] > 0) and (abilities_in_use[ability] != abilities_in_use[ability_direction_name])):
				abilities_in_use[ability]["priority"] += increment
		abilities_in_use[ability_direction_name]["priority"] += increment

func get_ability():
	var highest_priority_ability
	var lowest_priority_number = 5
	for ability in abilities_in_use:
		if ((abilities_in_use[ability]["priority"] < lowest_priority_number) and (abilities_in_use[ability]["priority"] > 0)):
			lowest_priority_number = abilities_in_use[ability]["priority"]
			highest_priority_ability = ability
	if highest_priority_ability:
		return highest_priority_ability
	return null

func use_ability(ability: String) -> void:
	if ability == "ability_up":
		abilities_in_use.ability_up.available = false
	elif ability == "ability_down":
		abilities_in_use.ability_down.available = false
	elif ability == "ability_left":
		abilities_in_use.ability_left.available = false
	elif ability == "ability_right":
		abilities_in_use.ability_right.available = false
	ui.update_ability_ui(abilities_in_use)

func refill_abilities() -> void:
	abilities_in_use.ability_up.available = true
	abilities_in_use.ability_down.available = true
	abilities_in_use.ability_left.available = true
	abilities_in_use.ability_right.available = true
	ui.update_ability_ui(abilities_in_use)

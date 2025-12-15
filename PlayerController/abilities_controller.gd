extends State

@export var dashing_state : State
@export var grappling_state : State
@export var climbing_state : State
@export var infated_state : State
@export var bounce_attack_state : State
@export var drill_state : State

@onready var ability_up = dashing_state
@onready var ability_down = dashing_state
@onready var ability_left = dashing_state
@onready var ability_right = dashing_state

@onready var abilities_in_use: Dictionary = {
	"ability_up": {
		"state" : ability_up, 
		"available" : true,
		"direction" : "up",
		},
	"ability_down": {
		"state" : ability_down, 
		"available" : true,
		"direction" : "down",
		},
	"ability_left": {
		"state" : ability_left, 
		"available" : true,
		"direction" : "left",
		},
	"ability_right": {
		"state" : ability_right, 
		"available" : true,
		"direction" : "right",
		},
	}

func get_ability(event: InputEvent) -> Dictionary:
	if event.is_action_pressed("ability_up"):
		return abilities_in_use.ability_up
	elif event.is_action_pressed("ability_down"):
		return abilities_in_use.ability_down
	elif event.is_action_pressed("ability_left"):
		return abilities_in_use.ability_left
	else: # event.is_action_pressed("ability_right"):
		return abilities_in_use.ability_right

func use_ability(event: InputEvent) -> void:
	if event.is_action_pressed("ability_up"):
		abilities_in_use.ability_up.available = false
	elif event.is_action_pressed("ability_down"):
		abilities_in_use.ability_down.available = false
	elif event.is_action_pressed("ability_left"):
		abilities_in_use.ability_left.available = false
	else: # event.is_action_pressed("ability_right"):
		abilities_in_use.ability_right.available = false

func refill_abilities() -> void:
	abilities_in_use.ability_up.available = true
	abilities_in_use.ability_down.available = true
	abilities_in_use.ability_left.available = true
	abilities_in_use.ability_right.available = true

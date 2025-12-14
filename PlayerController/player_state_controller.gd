extends CharacterBody2D

@onready var state_machine = $StateMachine

@export var normal_gravity : int = 65
@export var max_falling_speed : int = 2000

func _ready() -> void:
	state_machine.initialize(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

class_name Player
extends CharacterBody2D

@export var state_machine : StateMachine
@export var camera : Camera2D
@export_category("Room Transition Direction Rays")
@export var up : RayCast2D
@export var down : RayCast2D
@export var left : RayCast2D
@export var right : RayCast2D

@export var normal_gravity : int
@export var max_falling_speed : int
@onready var animated_player_sprite: AnimatedSprite2D = $AnimatedPlayerSprite

func _ready() -> void:
	state_machine.initialize(self,animated_player_sprite)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	if velocity.x < 0:
		animated_player_sprite.flip_h = true
	elif velocity.x > 0:
		animated_player_sprite.flip_h = false
	state_machine.process_frame(delta)

@warning_ignore("shadowed_variable_base_class")
func play_animation(name):
	if name == "":
		animated_player_sprite.play("no animation")
	else:
		animated_player_sprite.play(name)

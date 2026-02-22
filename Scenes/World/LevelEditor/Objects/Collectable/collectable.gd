class_name Collectable
extends Node2D

@export var value: int = 1

func _ready() -> void: 
	EventController.collectable_collected.connect(print_statement)

func _on_body_entered(body):
	if body is Player:
		GameController.collectable_collected(value)
		queue_free()

func print_statement(value: int):
	print("collected" ,value)

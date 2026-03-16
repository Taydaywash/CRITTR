class_name ChoicerHandler
extends Node

@onready var ui : UI = %UI

func on_confirm_pressed() -> void:
	pass

func on_cancel_pressed() -> void:
	ui.reset_choicer_text()

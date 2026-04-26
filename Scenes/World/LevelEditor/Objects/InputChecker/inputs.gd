extends Node2D

@export var first_sprite: Texture2D
@export var second_sprite: Texture2D
@export var third_sprite: Texture2D
@export var unknown: bool = false
@export var special: bool = false

func _ready() -> void:
	modulate.a = 0
	get_parent().connect("entered", unhide_sprite)
	get_parent().connect("exited", hide_sprite)
	if (!unknown):
		if first_sprite != null:
			$Sprite2D.texture = first_sprite
		if second_sprite != null:
			$Sprite2D2.texture = second_sprite
		if third_sprite != null:
			$Sprite2D3.texture = third_sprite


func unhide_sprite() -> void:
	var tween
	tween = create_tween()
	tween.tween_property(self, "modulate:a", .75, 1.5)
	
func hide_sprite() -> void:
	var tween
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5)

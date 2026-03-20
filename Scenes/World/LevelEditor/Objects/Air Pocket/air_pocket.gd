@tool
extends Node2D

@export var size: Vector2 = Vector2(128, 128):
	set(v):
		size = v
		_update_shape()

func _ready() -> void:
	_update_shape()

func _update_shape() -> void:
	var half := size / 2.0
	var verts := PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2( half.x, -half.y),
		Vector2( half.x,  half.y),
		Vector2(-half.x,  half.y),
	])
	if has_node("HoleShape"):
		$HoleShape.polygon = verts
	if has_node("Area2D/CollisionShape2D"):
		var shape := RectangleShape2D.new()
		shape.size = size
		$Area2D/CollisionShape2D.shape = shape

func _on_body_entered(_body: Node2D) -> void:
	print("entered")
	if get_parent().has_method("enter_air_pocket"):
		get_parent().enter_air_pocket()

func _on_body_exited(_body: Node2D) -> void:
	if get_parent().has_method("exit_air_pocket"):
		get_parent().exit_air_pocket()

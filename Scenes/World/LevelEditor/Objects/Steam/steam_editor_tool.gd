@tool
extends Node

@export var steam_variables : Area2D
@export var particles : CPUParticles2D
@export var collider: CollisionShape2D
var y_last_frame : int = 0
var x_last_frame : int = 0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if (y_last_frame == steam_variables.y) and (x_last_frame == steam_variables.x):
			return
		collider.shape.size.x = steam_variables.x
		collider.shape.size.y = steam_variables.y
		particles.position.y = steam_variables.y / 2.0
		particles.lifetime = steam_variables.y / 2560.0
		particles.amount = steam_variables.y / 3 + steam_variables.x / 3
		particles.emission_rect_extents = Vector2(steam_variables.x/2.0,0)
		#Makes sure the updates only happen when something changes
		y_last_frame = steam_variables.y
		x_last_frame = steam_variables.x

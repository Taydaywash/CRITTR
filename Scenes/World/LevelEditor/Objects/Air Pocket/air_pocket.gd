@tool
extends Node2D

@export var radius: float = 64.0:
	set(v):
		radius = v
		update_shape()

@export var wave_amplitude: float = 6.0
@export var wave_frequency: float = 4.0
@export var wave_speed: float = 2.0

var _time: float = 0.0

func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = radius
	$Area2D/CollisionShape2D.shape = shape
	update_shape()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		_time += delta
		update_visual() 

# I got this update shape logic online. Had to split the actual collision shape and 
# visuals to update separately because of issues with collision detection. 
func update_visual() -> void:
	var segments := 64
	var verts := PackedVector2Array()
	var fill_verts := PackedVector2Array()
	for i in range(segments):
		var angle := (float(i) / float(segments)) * TAU
		var wave := sin(angle * wave_frequency + _time * wave_speed) * wave_amplitude
		var r := radius + wave
		verts.append(Vector2(cos(angle) * r, sin(angle) * r))
		var r_fill := radius + wave + 6.0
		fill_verts.append(Vector2(cos(angle) * r_fill, sin(angle) * r_fill))
	if $HoleShape:
		$HoleShape.polygon = verts
	if $Fill:
		$Fill.polygon = verts

func update_shape() -> void:
	update_visual()
	if $Area2D/CollisionShape2D:
		var shape := CircleShape2D.new()
		shape.radius = radius
		$Area2D/CollisionShape2D.shape = shape

func _on_body_entered(body: Node2D) -> void:
	print("entered")
	if get_parent().has_method("enter_air_pocket"):
		get_parent().enter_air_pocket(body)

func _on_body_exited(body: Node2D) -> void:
	if get_parent().has_method("exit_air_pocket"):
		get_parent().exit_air_pocket(body)

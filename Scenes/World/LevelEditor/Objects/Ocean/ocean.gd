@tool
extends CanvasGroup

@export var size: Vector2 = Vector2(640, 640):
	set(v):
		size = v
		update_shape()

@export var breath_duration: float = 8.0

var player_in_water: Node2D = null
var in_air_pockets: int = 0
var tween: Tween = null

@onready var room : Room = $".."
@export_category("Sounds")
@export var water_enter_splash : AudioStream
@export var water_exit_splash : AudioStream
@export_category("Particles")
@export var water_enter_particle : PackedScene
@export var water_exit_particle : PackedScene

var audio_controller: AudioController
var particle_controller: ParticleController

func _ready() -> void:
	update_shape()
	room = $".."
	EventController.connect("player_death", _player_death)
	EventController.connect("player_respawn", _player_death)
	EventController.connect("entered_inflate_state",enter_air_pocket)
	EventController.connect("exited_inflate_state",exit_air_pocket)

	if not Engine.is_editor_hint():
		$BreathTimer.wait_time = breath_duration
		$BreathTimer.one_shot  = true
		
func _process(_delta):
	for body in $Area2D.get_overlapping_bodies():
		if body is CharacterBody2D and player_in_water == null:
			player_in_water = body
			start_breath_timer()
			start_tween(body)

func update_shape() -> void:
	var half := size / 2.0
	var verts := PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2( half.x, -half.y),
		Vector2( half.x,  half.y),
		Vector2(-half.x,  half.y),
	])
	if has_node("WaterShape"):
		$WaterShape.polygon = verts
	if has_node("Area2D/CollisionShape2D"):
		var shape := RectangleShape2D.new()
		shape.size = size
		$Area2D/CollisionShape2D.shape = shape

func _on_body_entered(body: Node2D) -> void:
	audio_controller = room.audio_controller
	audio_controller.enable_water_sound_filters()
	particle_controller = room.particle_controller
	start_tween(body)

	player_in_water = body
	particle_controller.spawn_particle($"../../../../Player",water_enter_particle)
	audio_controller.play_sound(water_enter_splash)
	start_breath_timer()

func _on_body_exited(body: Node2D) -> void:
	audio_controller = room.audio_controller
	audio_controller.disable_water_sound_filters()
	particle_controller = room.particle_controller
	end_tween(body)
	
	player_in_water = null
	particle_controller.spawn_particle($"../../../../Player",water_exit_particle)
	audio_controller.play_sound(water_exit_splash)
	$BreathTimer.stop()

func _on_breath_timeout() -> void:
	EventController.emit_signal("player_death")

func _player_death() -> void:
	if player_in_water:
		player_in_water.modulate = Color.WHITE
	if tween:
		tween.kill()
		$BreathTimer.stop()
		player_in_water = null

func start_breath_timer() -> void:
	$BreathTimer.wait_time = breath_duration
	$BreathTimer.start()

func enter_air_pocket(body: Node2D = $"../../../../Player") -> void:
	in_air_pockets += 1
	end_tween(body)
	audio_controller = room.audio_controller
	audio_controller.disable_water_sound_filters()
	particle_controller = room.particle_controller
	particle_controller.spawn_particle($"../../../../Player",water_exit_particle)
	audio_controller.play_sound(water_exit_splash)
	$BreathTimer.stop()

func exit_air_pocket(body: Node2D = $"../../../../Player") -> void:
	in_air_pockets -= 1
	if in_air_pockets > 0:
		return
	if not player_in_water:
		return
	in_air_pockets = 0
	start_tween(body)
	audio_controller = room.audio_controller
	audio_controller.enable_water_sound_filters()
	particle_controller = room.particle_controller
	particle_controller.spawn_particle($"../../../../Player",water_enter_particle)
	audio_controller.play_sound(water_enter_splash)
	
	if player_in_water:
		start_breath_timer()

		
func start_tween(body: Node2D) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(body, "modulate", Color.RED, breath_duration)
	
func end_tween(body: Node2D) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(body, "modulate", Color.WHITE, 0.5)

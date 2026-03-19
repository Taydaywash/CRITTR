extends Area2D

@export_category("Size")
@export var x: int = 128
@export var y: int = 386
@export_category("Timer")
@export var active_time: float = 2
@export var inactive_time: float = 2
@export var delay_time: float
@export var particles : CPUParticles2D

@export var collider: CollisionShape2D
@export var active_timer: Timer
@export var inactive_timer: Timer

@onready var room_reference = $".."
var is_room_active : bool = false

func _ready():
	room_reference.connect("room_is_active",room_is_active)
	room_reference.connect("room_is_inactive",room_is_inactive)
	collider.shape.size.x = x
	collider.shape.size.y = y
	particles.emitting = false
	particles.position.y = y/2.0
	particles.lifetime = (y / 2560.0)
	@warning_ignore("integer_division")
	particles.amount = y / 3 + x / 3
	particles.emission_rect_extents = Vector2(x/2.0,0)
	active_timer.wait_time = active_time - particles.lifetime
	inactive_timer.wait_time = inactive_time - particles.lifetime/2

func room_is_active():
	is_room_active = true
	await get_tree().create_timer(delay_time).timeout
	prepare_particles()
func room_is_inactive():
	active_timer.stop()
	inactive_timer.stop()
	clean_up_particles()
	is_room_active = false

func prepare_particles():
	if not is_room_active:
		return
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	if not is_room_active:
		return
	spawn_hitbox()
	active_timer.start()

func clean_up_particles():
	particles.emitting = false
	await get_tree().create_timer(particles.lifetime/2).timeout
	remove_hitbox()
	if not is_room_active:
		return
	inactive_timer.start()

func spawn_hitbox():
	collider.global_position = global_position
func remove_hitbox():
	collider.global_position = Vector2.INF

func _on_active_timer_timeout():
	clean_up_particles()

func _on_inactive_timer_timeout():
	prepare_particles()

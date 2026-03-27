extends Area2D

@export_category("Size")
@export var x: int = 128
@export var y: int = 386
@export_category("Timer")
@export var active_time: float = 2
@export var inactive_time: float = 2
@export var collider_growth_steps: int = 10
@export var delay_time: float
@export var particles : CPUParticles2D
@export var bubble_particles : CPUParticles2D

@export var collider: CollisionShape2D
@export var active_timer: Timer
@export var inactive_timer: Timer
@export var collider_growth_rate_timer: Timer

@onready var room_reference = $".."
var is_room_active : bool = false

signal steam_reset

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	room_reference.connect("room_is_active",room_is_active)
	room_reference.connect("room_is_inactive",room_is_inactive)
	collider.shape.size.x = x
	collider.shape.size.y = y
	particles.emitting = false
	collider.shape.size.y = 0
	collider.global_position = Vector2.INF
	#particles.position.y = y / 2.0
	particles.lifetime = (y / 2560.0)
	
	
	@warning_ignore("narrowing_conversion")
	particles.amount = y / 3.0 + ((x / 128.0)*100)
	@warning_ignore("narrowing_conversion")
	bubble_particles.amount = x / 2.0
	particles.emission_rect_extents = Vector2(x / 2.0, 0)
	bubble_particles.emission_rect_extents = Vector2(x / 2.0 + 64, 0)
	collider_growth_rate_timer.wait_time = particles.lifetime / collider_growth_steps
	active_timer.wait_time = active_time
	inactive_timer.wait_time = inactive_time

func room_is_active():
	process_mode = Node.PROCESS_MODE_INHERIT
	is_room_active = true
	spawn_bubbles(delay_time)
	await get_tree().create_timer(delay_time).timeout
	prepare_particles()
func room_is_inactive():
	if not is_room_active:
		return
	active_timer.stop()
	inactive_timer.stop()
	clean_up_particles()
	is_room_active = false
	process_mode = Node.PROCESS_MODE_DISABLED

func prepare_particles():
	particles.emitting = true
	spawn_hitbox()
	if not is_room_active:
		return
	active_timer.start()

func clean_up_particles():
	particles.emitting = false
	remove_hitbox()
	steam_reset.emit()
	if not is_room_active:
		return
	inactive_timer.start()
	spawn_bubbles(inactive_time)

func spawn_bubbles(delay):
	await get_tree().create_timer(delay - 0.8).timeout
	bubble_particles.emitting = true

func spawn_hitbox():
	collider.shape.size.y = 0
	collider.global_position = global_position
	collider_growth_rate_timer.wait_time = particles.lifetime / collider_growth_steps
	while collider.shape.size.y < y:
		collider_growth_rate_timer.start()
		await collider_growth_rate_timer.timeout
		if not is_room_active:
			break
		collider.shape.size.y += y / float(collider_growth_steps)
		collider.position.y = -collider.shape.size.y / 2.0
func remove_hitbox():
	collider.shape.size.y = y
	collider_growth_rate_timer.wait_time = particles.lifetime / collider_growth_steps / 2
	while collider.shape.size.y > 0:
		if not is_room_active:
			break
		if (collider.shape.size.y - y / float(collider_growth_steps)) > 0:
			collider.shape.size.y -= y / float(collider_growth_steps)
			collider.position.y = collider.shape.size.y / 2.0 - y
		else:
			collider.shape.size.y = 0
			collider.global_position = Vector2.INF
		collider_growth_rate_timer.start()
		await collider_growth_rate_timer.timeout

func _on_active_timer_timeout():
	clean_up_particles()

func _on_inactive_timer_timeout():
	prepare_particles()

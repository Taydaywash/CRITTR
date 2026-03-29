extends Area2D

@export_category("Size")
@export var x: int = 128
@export var y: int = 386
@export_category("Timer")
@export var active_time: float = 2
@export var inactive_time: float = 2
@export var collider_growth_steps: int = 10
@export var bubbling_duration: float = 0.8
@export var delay_time: float
@export var particles : CPUParticles2D
@export var bubble_particles : CPUParticles2D

@export var collider: CollisionShape2D
@export var active_timer: Timer
@export var inactive_timer: Timer
@export var collider_growth_rate_timer: Timer
@export var steam_delay_timer: Timer
@export var bubble_delay_timer: Timer

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
	particles.lifetime = (y / 2560.0)
	bubble_particles.lifetime = bubbling_duration
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
	if delay_time:
		spawn_bubbles(delay_time)
		steam_delay_timer.wait_time = delay_time
		steam_delay_timer.start()
		await steam_delay_timer.timeout
		if not is_room_active:
			return
	prepare_particles()

func room_is_inactive():
	is_room_active = false
	await get_tree().process_frame
	active_timer.stop()
	inactive_timer.stop()
	collider_growth_rate_timer.stop()
	bubble_delay_timer.stop()
	steam_delay_timer.stop()
	active_timer.timeout.emit()
	inactive_timer.timeout.emit()
	collider_growth_rate_timer.timeout.emit()
	bubble_delay_timer.timeout.emit()
	steam_delay_timer.timeout.emit()
	clean_up_particles(true)
	process_mode = Node.PROCESS_MODE_DISABLED

func prepare_particles():
	@warning_ignore("narrowing_conversion")
	particles.amount = y / 3.0 + ((x / 128.0)*100)
	particles.emitting = true
	spawn_hitbox()
	active_timer.start()

func clean_up_particles(instant : bool = false):
	particles.emitting = false
	if instant:
		particles.amount = 1
	remove_hitbox(instant)
	if not is_room_active:
		return
	steam_reset.emit()
	inactive_timer.start()

func spawn_bubbles(delay):
	if (delay - bubbling_duration) == 0:
		return
	if (delay - bubbling_duration) > 0:
		bubble_delay_timer.wait_time = delay - bubbling_duration
		bubble_particles.lifetime = bubbling_duration
		bubble_delay_timer.start()
		await bubble_delay_timer.timeout
		if not is_room_active:
			return
	else:
		bubble_particles.lifetime = bubbling_duration - delay
	bubble_particles.emitting = true

func spawn_hitbox():
	collider.shape.size.y = 0
	collider.global_position = global_position
	collider_growth_rate_timer.wait_time = particles.lifetime / collider_growth_steps
	while collider.shape.size.y < y:
		collider_growth_rate_timer.start()
		await collider_growth_rate_timer.timeout
		if not is_room_active:
			return
		collider.shape.size.y += y / float(collider_growth_steps)
		collider.position.y = -collider.shape.size.y / 2.0

func remove_hitbox(instant : bool = false):
	collider.shape.size.y = y
	collider_growth_rate_timer.wait_time = particles.lifetime / collider_growth_steps / 2
	if instant:
		collider.shape.size.y = 0
		collider.global_position = Vector2.INF
	while collider.shape.size.y > 0:
		if (collider.shape.size.y - y / float(collider_growth_steps)) > 0:
			collider.shape.size.y -= y / float(collider_growth_steps)
			collider.position.y = collider.shape.size.y / 2.0 - y
		else:
			collider.shape.size.y = 0
			collider.global_position = Vector2.INF
		collider_growth_rate_timer.start()
		await collider_growth_rate_timer.timeout
		if not is_room_active:
			return

func _on_active_timer_timeout():
	if not is_room_active:
		return
	clean_up_particles()
	spawn_bubbles(inactive_time)

func _on_inactive_timer_timeout():
	if not is_room_active:
		return
	prepare_particles()

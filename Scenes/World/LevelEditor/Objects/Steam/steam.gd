extends Area2D

@export_category("Size")
@export var x: int
@export var y: int
@export_category("Timer")
@export var active_time: float = 2
@export var inactive_time: float = 2
@export var delay_time: float

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var active_timer: Timer = $ActiveTimer
@onready var inactive_timer: Timer = $InactiveTimer


func _ready():
	active_timer.wait_time = active_time
	inactive_timer.wait_time = inactive_time
	collision.shape.size.x = x
	collision.shape.size.y = y
	active_timer.start()

func _on_active_timer_timeout():
	inactive_timer.start()
	self.monitorable = false
	self.visible = false

func _on_inactive_timer_timeout():
	active_timer.start()
	self.monitorable = true
	self.visible = true

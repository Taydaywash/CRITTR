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
	#These two following lines set the collision hitbox to zero
	#You can instead change the hitbox in the editor
	#collision.shape.size.x = x
	#collision.shape.size.y = y
	active_timer.start()

func _on_active_timer_timeout():
	inactive_timer.start()
	#Changing the position of the collision hitbox, rather than its monitorability
	#Causes it to immediately check for updates/Cause the player to immediately
	#detect it, rather than waiting for the player To leave and then reenter
	#...
	#This sets the collider's global position to (0,0) which is fine because no 
	#rooms exist at this point
	collision.global_position = Vector2.ZERO
	#self.monitorable = false
	self.visible = false

func _on_inactive_timer_timeout():
	active_timer.start()
	#This returns the collider's global position to that of the parent, returing
	#it to where it appears in the editor.
	collision.global_position = global_position
	#self.monitorable = true
	self.visible = true

func _on_body_entered(body: Node2D) -> void:
	print(body)

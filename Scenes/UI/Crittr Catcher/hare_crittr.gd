extends Sprite2D

@onready var north: RayCast2D = $North
@onready var east: RayCast2D = $East
@onready var south: RayCast2D = $South
@onready var west: RayCast2D = $West
@onready var crittr_catcher_ref = get_parent().get_parent().get_parent()

const IDLE = preload("uid://tj5sev1pwfaa")
const LOOK_DOWN = preload("uid://buvkr6x3vl2qv")
const LOOK_UP = preload("uid://dt1j4pxolbmjs")

var move_direction : String = ""
var facing : String = "east"
var between_look_delay : float = 0.1

func _ready() -> void:
	move()

func move() -> void:
	match move_direction:
		"north":
			position.y -= 128.0
		"east":
			position.x += 128.0
		"south":
			position.y += 128.0
		"west":
			position.x -= 128.0
	
	move_direction = ""
	crittr_catcher_ref.emit_signal("start_player_turn")
	await crittr_catcher_ref.start_crittr_turn
	await get_tree().create_timer(between_look_delay).timeout
	
	if not move_direction:
		check_right()
		await get_tree().create_timer(between_look_delay).timeout
		
	if not move_direction:
		check_left()
		await get_tree().create_timer(between_look_delay).timeout
		
	if not move_direction:
		check_forward()
		await get_tree().create_timer(between_look_delay).timeout
		
	if not move_direction:
		check_backward()
		await get_tree().create_timer(between_look_delay).timeout
		
	if not move_direction:
		move_direction = ""
	else:
		facing = move_direction
	move()

func look(direction : String) -> void:
	match direction:
		"north":
			#flip_h = sprite_flipped
			self.texture = LOOK_UP
		"east":
			flip_h = false
			self.texture = IDLE
		"south":
			#flip_h = sprite_flipped
			self.texture = LOOK_DOWN
		"west":
			flip_h = true
			self.texture = IDLE

func check_right() -> void:
	match facing:
		"north":
			look("east")
			if east.is_colliding():
				if east.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "east"
		"east":
			look("south")
			if south.is_colliding():
				if south.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "south"
		"south":
			look("west")
			if west.is_colliding():
				if west.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "west"
		"west":
			look("north")
			if north.is_colliding():
				if north.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "north"

func check_left() -> void:
	match facing:
		"north":
			look("west")
			if west.is_colliding():
				if west.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "west"
		"east":
			look("north")
			if north.is_colliding():
				if north.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "north"
		"south":
			look("east")
			if east.is_colliding():
				if east.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "east"
		"west":
			look("south")
			if south.is_colliding():
				if south.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "south"

func check_forward() -> void:
	match facing:
		"north":
			look("north")
			if north.is_colliding():
				if north.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "north"
		"east":
			look("east")
			if east.is_colliding():
				if east.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "east"
		"south":
			look("south")
			if south.is_colliding():
				if south.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "south"
		"west":
			look("west")
			if west.is_colliding():
				if west.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "west"

func check_backward() -> void:
	match facing:
		"north":
			look("south")
			if south.is_colliding():
				if south.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "south"
		"east":
			look("west")
			if west.is_colliding():
				if west.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "west"
		"south":
			look("north")
			if north.is_colliding():
				if north.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "north"
		"west":
			look("east")
			if east.is_colliding():
				if east.get_collider().get_parent() is CrittrCatcherPlayer:
					return
				move_direction = "east"

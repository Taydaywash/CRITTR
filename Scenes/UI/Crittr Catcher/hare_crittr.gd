extends Sprite2D

@onready var north: RayCast2D = $North
@onready var east: RayCast2D = $East
@onready var south: RayCast2D = $South
@onready var west: RayCast2D = $West
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var overlapping: RayCast2D = $Overlapping

@onready var crittr_catcher_ref = get_parent().get_parent().get_parent()



const HARE_IDLE = preload("uid://tj5sev1pwfaa")
const HARE_LOOK_DOWN = preload("uid://buvkr6x3vl2qv")
const HARE_LOOK_UP = preload("uid://dt1j4pxolbmjs")

const FROG_IDLE = preload("uid://dao8xsxy0m5db")
const FROG_LOOK_DOWN = preload("uid://gfbrycuk24yw")
const FROG_LOOK_UP = preload("uid://cg7s0vrcq6gd3")

const LIZARD_IDLE = preload("uid://c35245rkb81mk")
const LIZARD_LOOK_DOWN = preload("uid://biliwq8n5ny3e")
const LIZARD_LOOK_UP = preload("uid://c8rmaqo3rke8c")

const PUFFER_IDLE = preload("uid://30onrtd08d6v")
const PUFFER_LOOK_DOWN = preload("uid://cup2g5bjtf01x")
const PUFFER_LOOK_UP = preload("uid://tidnwhpolj20")

var IDLE = HARE_IDLE
var LOOK_DOWN = HARE_LOOK_DOWN
var LOOK_UP = HARE_LOOK_UP

var move_direction : String = ""
@export var facing : String = "east"
var between_look_delay : float = 0.1
var level_deactivated : bool = false

@export var crittr = "hare"
var crittr_turn : bool = false

func _ready() -> void:
	match crittr:
		"hare":
			IDLE = HARE_IDLE
			LOOK_DOWN = HARE_LOOK_DOWN
			LOOK_UP = HARE_LOOK_UP
		"frog":
			IDLE = FROG_IDLE
			LOOK_DOWN = FROG_LOOK_DOWN
			LOOK_UP = FROG_LOOK_UP
		"lizard":
			IDLE = LIZARD_IDLE
			LOOK_DOWN = LIZARD_LOOK_DOWN
			LOOK_UP = LIZARD_LOOK_UP
		"puffer":
			IDLE = PUFFER_IDLE
			LOOK_DOWN = PUFFER_LOOK_DOWN
			LOOK_UP = PUFFER_LOOK_UP
	look(facing)
	crittr_catcher_ref.connect("start_crittr_turn",func end_player_turn():
		crittr_turn = true
		move()
		)
	crittr_catcher_ref.connect("close_crittr_catcher",func end_player_turn():
		crittr_turn = false
		)


func _process(_delta: float) -> void:
	match facing:
		"north":
			%FacingArrow.rotation_degrees = 270
			%FacingArrow.position = Vector2(0,-250)
		"east":
			%FacingArrow.rotation_degrees = 0
			%FacingArrow.position = Vector2(250,0)
		"south":
			%FacingArrow.rotation_degrees = 90
			%FacingArrow.position = Vector2(0,250)
		"west":
			%FacingArrow.rotation_degrees = 180
			%FacingArrow.position = Vector2(-250,0)
	
	if overlapping.is_colliding() and not level_deactivated:
		level_deactivated = true
		var overlapping_collider = overlapping.get_collider().get_parent()
		animation_player.play("Fade_Out")
		await animation_player.animation_finished
		if overlapping_collider is CrittrCatcherPlayer:
			crittr_catcher_ref.next_level()
			return
		crittr_catcher_ref.restart_level()

func move() -> void:
	north.force_raycast_update()
	east.force_raycast_update()
	south.force_raycast_update()
	west.force_raycast_update()
	await get_tree().create_timer(between_look_delay).timeout
	if facing == "east":
		look_for_exit()
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

func look(direction : String) -> void:
	match direction:
		"north":
			#flip_h = sprite_flipped
			texture = LOOK_UP
		"east":
			flip_h = false
			texture = IDLE
		"south":
			#flip_h = sprite_flipped
			texture = LOOK_DOWN
		"west":
			flip_h = true
			texture = IDLE

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

func look_for_exit() -> void:
	if east.is_colliding():
		look_for_exit_loop(east.get_collider().get_parent())

func look_for_exit_loop(node) -> void:
	if not node.has_node("%Right"):
		if node is CrittrCatcherExitNode:
			move_direction = "east"
		return
	if node.get_node("%Right").get_collider().get_parent() is CrittrCatcherExitNode:
		move_direction = "east"
		return
	look_for_exit_loop(node.get_node("%Right").get_collider().get_parent())

class_name CrittrCatcherPlayer
extends Sprite2D

@onready var north: RayCast2D = $North
@onready var east: RayCast2D = $East
@onready var south: RayCast2D = $South
@onready var west: RayCast2D = $West
@onready var crittr_catcher_ref = get_parent().get_parent().get_parent()
@onready var ui : UI = crittr_catcher_ref.get_node("%UI")
@onready var choicer_handler : ChoicerHandler = crittr_catcher_ref.get_node("%CrittrCatcherChoicerHandler")

var player_turn : bool = false
var choicer_active : bool = false

func _ready() -> void:
	crittr_catcher_ref.connect("start_player_turn",func start_player_turn():
		player_turn = true
		)
	crittr_catcher_ref.connect("close_crittr_catcher",func end_player_turn():
		player_turn = false
		)

func _process(_delta: float) -> void:
	choicer_active = crittr_catcher_ref.choicer_active

func _input(event: InputEvent) -> void:
	if choicer_active:
		return
	if not player_turn:
		return
	if event.is_action_pressed("move_up"):
		if not north.is_colliding():
			return
		position.y -= 128.0
		crittr_catcher_ref.emit_signal("start_crittr_turn")
		player_turn = false
	if event.is_action_pressed("move_down"):
		if not south.is_colliding():
			return
		position.y += 128.0
		crittr_catcher_ref.emit_signal("start_crittr_turn")
		player_turn = false
	if event.is_action_pressed("move_left"):
		if not west.is_colliding():
			return
		position.x -= 128.0
		crittr_catcher_ref.emit_signal("start_crittr_turn")
		player_turn = false
	if event.is_action_pressed("move_right"):
		if not east.is_colliding():
			return
		if right_has_exit():
			ui.start_typing_choicer_text(Dialog.CRITTR_CATCHER_LEAVE,choicer_handler)
			return
		position.x += 128.0
		crittr_catcher_ref.emit_signal("start_crittr_turn")
		player_turn = false
func right_has_exit() -> bool:
	if east.is_colliding():
		if east.get_collider().get_parent() is CrittrCatcherExitNode:
			return true
	return false

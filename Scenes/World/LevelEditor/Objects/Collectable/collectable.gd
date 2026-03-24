class_name Collectable
extends Node2D

@export var value: int = 1
@export var room_name: String = ""

var id: String = ""
var following_player : bool = false
var player = null

func _ready() -> void: 
	EventController.connect("collectable_following",func collectable_following(identifier,player_ref):
		if identifier == id:
			player = player_ref
			following_player = true
		)
	if room_name == "":
		room_name = get_parent().name
	id = "%s_collectable_%s_%s" % [room_name, global_position.x, global_position.y]
	if GameController.is_collected(id):
		queue_free()
		return

func _on_body_entered(body):
	if body is Player:
		print(id)
		EventController.emit_signal("collectable_grabbed", id)
		set_deferred("monitoring",false)

func _process(delta: float) -> void:
	if not following_player:
		return
	global_position = lerp(global_position,player.global_position,delta * 5)
	if player.can_collect():
		EventController.emit_signal("collectable_collected", id, value)
		queue_free()

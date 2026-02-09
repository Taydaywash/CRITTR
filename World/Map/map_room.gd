class_name MapRoom
extends Polygon2D

@export var outline : Line2D

var corresponding_room : Room = null

func _process(delta: float) -> void:
	if corresponding_room:
		if corresponding_room.room_transition_controller.current_room == corresponding_room:
			color = Color.WHITE
		else:
			color = Color.GRAY

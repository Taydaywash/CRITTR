extends Label
class_name SingleViewText
var room : Room
func _ready() -> void:
	room = get_parent()

func _process(_delta: float) -> void:
	if room.room_visited and room.room_transition_controller.current_room != room:
		queue_free()

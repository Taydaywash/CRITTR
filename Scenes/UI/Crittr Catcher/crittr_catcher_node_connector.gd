class_name CrittrCatcherNode
extends Sprite2D

func _physics_process(_delta: float) -> void:
	for child in get_children():
		if child is Line2D:
			child.get_child(0).force_raycast_update()
			if not child.get_child(0).is_colliding():
				child.queue_free()

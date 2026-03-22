extends Path2D

@export var speed: float = .4

func _process(delta):
	$PathFollow2D.progress_ratio += delta * speed

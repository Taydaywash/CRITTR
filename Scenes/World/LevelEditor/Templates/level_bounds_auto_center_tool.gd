@tool
extends CollisionShape2D

func _process(_delta: float):
	if self.position:
		self.position = Vector2.ZERO

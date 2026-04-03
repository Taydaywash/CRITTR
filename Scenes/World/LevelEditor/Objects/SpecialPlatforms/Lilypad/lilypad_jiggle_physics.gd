extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $"../CollisionShape2D"
@onready var jiggle_area: CollisionShape2D = $jiggleArea
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
var initiated : bool = false

func _ready() -> void:
	jiggle_area.shape = collision_shape_2d.shape
	await get_tree().create_timer(randf_range(0,1)).timeout
	initiated = true
	animation_player.play("sway")
func _process(_delta: float) -> void:
	if not initiated:
		return
	if not animation_player.is_playing():
		animation_player.play("sway")
func _on_jiggle_entered(_body: Node2D) -> void:
	animation_player.play("jiggle")

extends TileMapLayer

var fade_tile_out : bool = false
@onready var id = "%s(%s,%s)" % [name,global_position.x,global_position.y]
func _ready() -> void:
	if id in GameController.game_state.revealed_walls:
		queue_free()
	EventController.connect("on_hidden_tile_entered",func begin_hide_tile(body):
		if body == self:
			EventController.emit_signal("wall_revealed",id)
			fade_tile_out = true
	)
func _process(delta: float) -> void:
	if not fade_tile_out:
		return
	modulate.a = move_toward(modulate.a,0.0,delta*2)
	if modulate.a == 0:
		queue_free()

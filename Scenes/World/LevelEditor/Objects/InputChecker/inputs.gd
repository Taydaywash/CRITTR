extends Node2D

@export var first_sprite: Texture2D
@export var second_sprite: Texture2D
@export var third_sprite: Texture2D
@export var unknown: bool = false
@export var special: bool = false

var number: int

func _ready() -> void:
	modulate.a = 0
	var parent = get_parent()
	parent.connect("entered", _on_parent_entered)
	parent.connect("exited", _on_parent_exited)
	refresh_state()

func _on_parent_entered() -> void:
	refresh_state()
	unhide_sprite()

func _on_parent_exited() -> void:
	hide_sprite()

func refresh_state() -> void:
	number = get_number()

	check_special(number)
	update_sprite_textures()

func update_sprite_textures() -> void:
	if not unknown:
		if first_sprite:
			$Sprite2D.texture = first_sprite
		if second_sprite:
			$Sprite2D2.texture = second_sprite
		if third_sprite:
			$Sprite2D3.texture = third_sprite

func check_special(id: int) -> void:
	if special and id != -1:
		var sequences = GameController.game_state.sequences_unlocked

		if sequences.has(id):
			if sequences[id] == true:
				unknown = false
		elif sequences.has(str(id)):
			if sequences[str(id)] == true:
				unknown = false

func get_number() -> int:
	if self.name == "InputSpecial1": return 1
	if self.name == "InputSpecial2": return 2
	if self.name == "InputSpecial3": return 3
	return -1

func unhide_sprite() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.75, 1.5)
	
func hide_sprite() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5)

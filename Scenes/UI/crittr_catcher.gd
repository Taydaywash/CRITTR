class_name CrittrCatcher
extends CanvasLayer

@export var animation_player: AnimationPlayer
@export var screen : TextureRect
@export var ui: UI

@warning_ignore("unused_signal")
signal start_crittr_turn
@warning_ignore("unused_signal")
signal start_player_turn
@warning_ignore("unused_signal")
signal close_crittr_catcher

var initial_level : int = 0
var choicer_active : bool = false
var current_scene : PackedScene
var current_scene_index : int = 0

const EMPTY_LEVEL = preload("uid://bvyhblatdsy7i")

const ARCTIC_HARE_LEVEL_ONE = preload("uid://b5fudtphkrx1c")
const ARCTIC_HARE_LEVEL_TWO = preload("uid://du1qntg4cje4j")
const ARCTIC_HARE_LEVEL_THREE = preload("uid://dr2aaabjokk7i")
const ARCTIC_HARE_LEVEL_FOUR = preload("uid://cehn5odetaf3e")

const ARCTIC_HARE_LEVEL_POOL : Dictionary = {
	0 : ARCTIC_HARE_LEVEL_ONE,
	1 : ARCTIC_HARE_LEVEL_TWO,
	2 : ARCTIC_HARE_LEVEL_THREE,
	3 : ARCTIC_HARE_LEVEL_FOUR,
}
const ACID_FROG_LEVEL_POOL : Dictionary = {
	0 : ARCTIC_HARE_LEVEL_ONE,
	1 : ARCTIC_HARE_LEVEL_TWO,
	2 : ARCTIC_HARE_LEVEL_THREE,
	3 : ARCTIC_HARE_LEVEL_FOUR,
}

#Changes depending on the den interacted with
var level_pool : Dictionary
var ability_to_unlock : String

func _ready() -> void:
	ui.choicer_dialog.connect("choicer_active",func choicer_active():
		choicer_active = true
		)
	ui.choicer_dialog.connect("choicer_inactive",func choicer_inactive():
		choicer_active = false
		)
	#animation_player.play("enter_crittr_catcher")

func change_level_to(scene : PackedScene) -> void:
	for child in screen.get_children():
		child.queue_free()
	current_scene = scene
	var current_scene_instance = current_scene.instantiate()
	screen.add_child(current_scene_instance)
	await current_scene_instance.get_node("%AnimationPlayer").animation_finished
	if current_scene != EMPTY_LEVEL:
		start_player_turn.emit()

func restart_level() -> void:
	change_level_to(current_scene)

func next_level() -> void:
	if current_scene_index >= len(level_pool) - 1:
		exit_crittr_catcher()
		await animation_player.animation_finished
		EventController.emit_signal("unlock_ability",ability_to_unlock)
		ui.text_popup.start_typing_text(Dialog.ABILITY_GAINED)
		return
	current_scene_index += 1
	change_level_to(level_pool[current_scene_index])

func enter_crittr_catcher(new_level_pool : Dictionary, new_ability_to_unlock : String):
	current_scene_index = 0
	ability_to_unlock = new_ability_to_unlock
	level_pool = new_level_pool
	animation_player.play("enter_crittr_catcher")
	await animation_player.animation_finished
	change_level_to(level_pool[current_scene_index])

func exit_crittr_catcher():
	animation_player.play("exit_crittr_catcher")
	emit_signal("close_crittr_catcher")
	change_level_to(EMPTY_LEVEL)
	await animation_player.animation_finished
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug Menu"):
		initial_level += 1
		change_level_to(level_pool[initial_level])
		start_player_turn.emit()

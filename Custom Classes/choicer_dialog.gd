class_name ChoicerDialog
extends Panel

@export var text : RichTextLabel
@export var confirm_button : Button
@export var cancel_button : Button
@export var type_sound : AudioStream
@export var ui: UI
var current_text_index : int = 0
var dialog_length : int
var cancel_typing : bool = false
var currently_typing : bool = false
var text_delay_timer : Timer

const punctuation : Array = [".","?","!"]

var choicer_handler : ChoicerHandler

signal choicer_active
signal choicer_inactive

func _ready() -> void:
	text_delay_timer = Timer.new()
	text_delay_timer.one_shot = true
	add_child(text_delay_timer)
	reset_text()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		text.visible_characters += 10

func reset_text() -> void:
	await get_tree().create_timer(0.05).timeout
	choicer_inactive.emit()
	visible = false
	confirm_button.visible = false
	cancel_button.visible = false
	text.visible_characters = 0

func start_typing_text(dialog : String,choicer_handler_reference : ChoicerHandler) -> void:
	choicer_active.emit()
	choicer_handler = choicer_handler_reference
	visible = true
	text.text = dialog
	dialog_length = text.get_total_character_count()
	text.visible_characters = 0
	current_text_index = 0
	typing_loop()

func stop_typing() -> void:
	text_delay_timer.stop()
	cancel_typing = true

func typing_loop() -> void:
	currently_typing = true
	text_delay_timer.wait_time = SaveLoadManager.options.text_speed
	text.visible_characters += 1 + floori(get_process_delta_time() * 20)
	if text.visible_characters > len(text.text):
		text.visible_characters = len(text)
	if SaveLoadManager.options.text_speed == 0:
		text.visible_characters = -1
	current_text_index = text.visible_characters - 1
	ui.audio_controller.play_sound(type_sound,2,2)
	if text.text[current_text_index] in punctuation:
		text_delay_timer.wait_time = 0.6
	text_delay_timer.start()
	await text_delay_timer.timeout
	if cancel_typing:
		finished_typing()
		return
	if text.visible_characters >= dialog_length:
		finished_typing()
		return
	typing_loop()

func finished_typing() -> void:
	text_delay_timer.stop()
	cancel_typing = false
	currently_typing = false
	confirm_button.visible = true
	cancel_button.visible = true
	confirm_button.grab_focus()

func _on_confirm_pressed() -> void:
	choicer_handler.on_confirm_pressed()
func _on_cancel_pressed() -> void:
	choicer_handler.on_cancel_pressed()

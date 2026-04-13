extends Area2D

signal sequence_matched()

@export var buffer_size: int = 10
@export var input_timeout: float = 2.0
@export var sequences: Array[String]

var watched_actions: Array[String] = ["jump", "dive", "move_left", "move_right", "move_up", "move_down"]
var input_buffer: Array[String] = []
var player_inside: bool = false

func _ready():
	$Timer.wait_time = input_timeout

func _unhandled_input(_event: InputEvent) -> void:
	if not player_inside:
		return
	for action in watched_actions:
		if Input.is_action_just_pressed(action):
			print(action)
			register_input(action)

func register_input(action_name: String) -> void:
	$Timer.stop()
	$Timer.start()
	input_buffer.append(action_name)
	if input_buffer.size() > buffer_size:
		input_buffer.pop_front()
	check_sequences()

func check_sequences() -> void:
	var length: int = sequences.size()
	#print("Buffer: ", input_buffer)  # add this
	#print("Expecting: ", sequences)  # add this
	if input_buffer.size() < length:
		return
	var tail = input_buffer.slice(input_buffer.size() - length)
	if tail == sequences:
		sequence_matched.emit()
		print("match")
		input_buffer.clear()
		$Timer.stop()

func _on_body_entered(body):
	if body is Player:
		player_inside = true
		input_buffer.clear()

func _on_body_exited(body):
	if body is Player:
		player_inside = false
		input_buffer.clear()
		$Timer.stop()

func _on_timer_timeout():
	input_buffer.clear()

extends Node

@onready var player: CharacterBody2D = $"../PlayerController"

@export var up_velocity_room_transition : float
@export var down_velocity_room_transition : float
@export var x_velocity_room_transition : float
@export var first_room : Room
@export var screen_fade_speed : float
@onready var ui: CanvasLayer = $"../UI"

var previous_room : Room
var current_room : Room = null
var next_room : Room
var fade_in : bool
var fade_out : bool

func _ready() -> void:
	current_room = first_room
	first_room.enter_room()

func entered_room(room : Room):
	next_room = room

func exited_room(room : Room):
	if room == current_room:
		previous_room = current_room
		current_room = null
		fade_in = true
		fade_out = false
	else:
		next_room = null

func _process(delta: float) -> void:
	if fade_in:
		ui.screen_overlay.modulate.a = lerp(ui.screen_overlay.modulate.a,1.0,delta * screen_fade_speed)
		if ui.screen_overlay.modulate.a >= 0.99:
			ui.screen_overlay.modulate.a = 1.0
			fade_in = false
	if fade_out:
		ui.screen_overlay.modulate.a = lerp(ui.screen_overlay.modulate.a,0.0,delta * screen_fade_speed)
		if ui.screen_overlay.modulate.a <= 0.01:
			ui.screen_overlay.modulate.a = 0.0
			fade_out = false
	if !current_room and next_room:
		if player.velocity.y < 0:
			player.velocity.y = -up_velocity_room_transition
		elif player.velocity.y > 0:
			player.velocity.y = down_velocity_room_transition
		elif player.velocity.x > 0:
			player.velocity.x = x_velocity_room_transition
		elif player.velocity.x < 0:
			player.velocity.x = -x_velocity_room_transition
		if !fade_in and !fade_out:
			fade_out = true
			previous_room.exit_room()
			current_room = next_room
			next_room.enter_room()

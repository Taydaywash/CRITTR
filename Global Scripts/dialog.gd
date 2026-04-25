extends Node

var from_string : Dictionary = {
	"TELEPORT_CONFIRMATION":TELEPORT_CONFIRMATION,
	"ARCTIC_HARE_DEN":ARCTIC_HARE_DEN,
	"ACID_FROG_DEN":ACID_FROG_DEN,
	"INFLATE_DEN":INFLATE_DEN,
	"END_GAME_CONFIRMATION":END_GAME_CONFIRMATION,
}

const TELEPORT_CONFIRMATION = ("Are you sure you want to teleport to this save tube?")

const END_GAME_CONFIRMATION = ("Are you sure you want to end the crittr demo? \n (Game progress will be saved)")

const CRITTR_CATCHER_LEAVE = ("Are you sure you want to exit this crittr den? 
(progress will be lost)")

const ARCTIC_HARE_DEN = ("A den sits before you. Rhythmic zapping can be heard from inside.
Scans suggest that this den belongs to an 'Arctic Hare'.
\nInsert Crittr Catcher 9000?")

const ACID_FROG_DEN = ("A den sits before you. Croaking and sploinking can be heard from inside.
Scans suggest that this den belongs to a 'Grapple Frog'.
\nInsert Crittr Catcher 9000?")

const INFLATE_DEN = ("A den sits before you. Balloon-like stretching can be heard from inside.
Scans suggest that this den belongs to a 'Pufferfly'.
\nInsert Crittr Catcher 9000?")

const SCRAP_COLLECTED = ("You got a Strange Scrap!
Maybe it'll come in handy some day?")

const ABILITY_GAINED = ("You gained a new ability! 
Equip it at any save point 
(You can use the map to teleport to one)")

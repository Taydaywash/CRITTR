@tool
extends StaticBody2D

@export_range(3, 5, 1) var width : int
@export_range(1, 3, 1) var stem_variation : int

const LILYPAD_STEM_1 = preload("res://Assets/Decals/Marsh/Platforms/lilypadStem1.png")
const LILYPAD_STEM_2 = preload("res://Assets/Decals/Marsh/Platforms/lilypadStem2.png")
const LILYPAD_STEM_3 = preload("res://Assets/Decals/Marsh/Platforms/lilypadStem3.png")

const LILYPAD_PLATFORM_3 = preload("res://Scenes/World/LevelEditor/Objects/SpecialPlatforms/Lilypad/Colliders/LilypadPlatform3.tres")
const LILYPAD_PLATFORM_4 = preload("res://Scenes/World/LevelEditor/Objects/SpecialPlatforms/Lilypad/Colliders/LilypadPlatform4.tres")
const LILYPAD_PLATFORM_5 = preload("res://Scenes/World/LevelEditor/Objects/SpecialPlatforms/Lilypad/Colliders/LilypadPlatform5.tres")

const LILYPAD_3 = preload("res://Assets/Decals/Marsh/Platforms/lilypad3.png")
const LILYPAD_4 = preload("res://Assets/Decals/Marsh/Platforms/lilypad4.png")
const LILYPAD_5 = preload("res://Assets/Decals/Marsh/Platforms/lilypad5.png")

func _ready() -> void:
	match width:
		3: 
			$LilypadPlatform.texture = LILYPAD_3
			$CollisionShape2D.shape = LILYPAD_PLATFORM_3
		4: 
			$LilypadPlatform.texture = LILYPAD_4
			$CollisionShape2D.shape = LILYPAD_PLATFORM_4
		5: 
			$LilypadPlatform.texture = LILYPAD_5
			$CollisionShape2D.shape = LILYPAD_PLATFORM_5
	match stem_variation:
		1: $Stem.texture = LILYPAD_STEM_1
		2: $Stem.texture = LILYPAD_STEM_2
		3: $Stem.texture = LILYPAD_STEM_3
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		match width:
			3: 
				$LilypadPlatform.texture = LILYPAD_3
				$CollisionShape2D.shape = LILYPAD_PLATFORM_3
			4: 
				$LilypadPlatform.texture = LILYPAD_4
				$CollisionShape2D.shape = LILYPAD_PLATFORM_4
			5: 
				$LilypadPlatform.texture = LILYPAD_5
				$CollisionShape2D.shape = LILYPAD_PLATFORM_5
	match stem_variation:
		1: $Stem.texture = LILYPAD_STEM_1
		2: $Stem.texture = LILYPAD_STEM_2
		3: $Stem.texture = LILYPAD_STEM_3

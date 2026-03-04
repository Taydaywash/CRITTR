@icon("res://Assets/Editor Icons/Level Editor Objects/Respawn point Icon.png")
class_name RespawnPoint
extends Node2D

@export var respawn_point_ray : RayCast2D

func get_respawn_point():
	respawn_point_ray.force_raycast_update()
	assert(respawn_point_ray.is_colliding(),"%s Tried to get respawn point at %s but the ray never 
	touched the ground" % [self.name, respawn_point_ray.get_parent().get_parent()])
	return Vector2(respawn_point_ray.get_collision_point().x,respawn_point_ray.get_collision_point().y - 100)

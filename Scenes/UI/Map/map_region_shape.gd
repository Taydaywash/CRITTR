class_name MapRegionShape
extends CollisionPolygon2D

@export var outline : Line2D
@export var region_shape : Polygon2D
@export_category("Map Render Paremeters")
@export var outline_thickness : int

var map_controller = null
var corresponding_region : Region

func _ready() -> void:
	if corresponding_region:
		region_shape.color = corresponding_region.map_color
	else:
		region_shape.color = Color.AQUA
	region_shape.uv = region_shape.polygon
	outline.width = outline_thickness
	outline.default_color = Color()

func _process(_delta: float) -> void:
	if map_controller:
		visible = map_controller.show_regions

tool
extends Node2D

onready var camera = $player/pivot/offset/camera as Camera2D

func _ready():
	set_camera_limits()

func set_camera_limits() -> void:
	var map_limits = get_node("map").get_child(0).get_used_rect()
	var map_cellsize = get_node("map").get_child(0).cell_size.round()
	
	#лимитируем передвижение камеры до размера карты
	camera.limit_left = 0
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y

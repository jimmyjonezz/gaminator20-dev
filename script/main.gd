extends Node2D

onready var camera = $player/pivot/offset/camera as Camera2D
onready var shader = get_node("shaders/control").get_children()
onready var spawn_key = get_node("spawn_key").get_children()

#значения спавна дверей для выхода и ключа
var exit_door_spawn = [Vector2(424, 142), Vector2(1208, 142), 
		Vector2(1448, 238), Vector2(1784, 382), Vector2(88, 334)]
#var key_spawn = [Vector2(775, 286), Vector2(536, 238), Vector2(1446, 192), Vector2(1550, 96)]
var key_spawn = [] as Array

func _ready():
	set_camera_limits()
	
	randomize()
	#спавним ключ
	for x in spawn_key:
		key_spawn.push_back(x.position)
	
	var spawn_key_point = key_spawn[randi() % key_spawn.size()]
	$stuff/key1.position = spawn_key_point
	printt("position key:", spawn_key_point)
	
	#заводим массив с позициями enemy - на будущее
	var spawn_enemy = get_node("enemys/ysort").get_children()
	var sd = []
	for x in spawn_enemy:
		var m = "Vector2%s" % x.position
		sd.push_back(m)

func set_camera_limits() -> void:
	#берем границы tilemap - back
	var map_limits = get_node("map").get_child(0).get_used_rect()
	var map_cellsize = get_node("map").get_child(0).cell_size.round()
	
	#лимитируем передвижение камеры до размера карты
	camera.limit_left = 0
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y

#вырубаем шейдеры
func _on_shader_time_timeout():
	for x in shader:
		if x as TextureRect:
			x.visible = false

#взяли ключ? тогда меняем позицию двери установив в одну из случайных позиций
func _on_key1_pickup():
	$ui/key.visible = true
	var spawn_door_point = exit_door_spawn[randi() % exit_door_spawn.size()]
	$stuff/door.position = spawn_door_point
	printt("position door:", spawn_door_point)
	yield(get_tree().create_timer(0.5),"timeout")
	$sound/door.play()

extends KinematicBody2D

#signal died()

export var Ammo : PackedScene
export var Bullet: PackedScene
var shooting = false
var save = false
var nums = [true, false]
var died = false
var too_close = false
var state_machine
var hard = false

onready var props = get_node("../../../props")
onready var tiles = get_node("../../../map").get_child(1)

#export (int) var speed = 2000
var velocity = Vector2.ZERO
var rand_dis = 30

func in_map():
	var tpos = tiles.world_to_map(get_global_position())
	var itile = tiles.get_cellv(Vector2(tpos.x, tpos.y + 1))
	return itile

func _on_area2d_area_entered(area):
	if area.enemy == true:
		return
		
	if area.name == "bullet":
		die()
		
func shoot() -> void:
	var bullet_count = 1
	if hard:
		bullet_count = 2
	if shooting == false and died == false:
		$timer.start()
		for i in range(bullet_count):
			var bullet = Bullet.instance()
			
			var rot = get_rotation()
			if $sprite.flip_h:
				rot += PI
			
			bullet.start($pos.global_position, rot)
			get_parent().add_child(bullet)
			yield(get_tree().create_timer(0.1), "timeout")
		
func die():
	died = true
	$"../../../ui".kills()
	$animation.play("die")
	set_physics_process(false)
	$rebirth.start()
	$raycast.enabled = false
	$timer.stop()
	$collision.set_deferred("disabled", true)
	$area2d/area_collision.set_deferred("disabled", true)
	$die.play()
	$dir_timer.stop()
	_spawn_props()
	#queue_free()
	
func _ready():
	randomize()
	rand_dis = rand_range(30, 35)
	#случайное направление влево или вправо
	var dir = nums[randi() % nums.size()]
	if dir:
		$sprite/head.visible = false
		_rotation()
	#случайное значение шкалы времени для анимации idle
	$animation.seek(rand_range(0, 0.6))
	#время задержки при смене направления flip_h
	$dir_timer.wait_time = rand_range(3, 5)
	$timer.start()
	$dir_timer.start()
	state_machine = $animtree.get("parameters/playback")
	set_physics_process(false)

func _process(delta):
	#луч рэйкаста чего-то касается?
	var target_dis = $raycast.is_colliding()
	#если да, то флаг активен и можно стрелять
	if target_dis:
		
		var pos = $raycast.get_collision_point()
		
		if pos.distance_to(self.global_position) < rand_dis:
			too_close = true
		else:
			too_close = false
		
		$atention.visible = true

		if !save:
			yield(get_tree().create_timer(0.3), "timeout")
			shoot()
			
		shooting = true
	else:
		$atention.visible = false
		too_close = false

var walk_state = 0
var nxt_walk = 0

func _physics_process(delta):
	if died:
		return
	#задел на хождение enemy
	
	if save or died or shooting or too_close:
		walk_state = 0
	else:
		if nxt_walk < autoload.time:
			walk_state = randi() % 2
			nxt_walk = autoload.time + 2
	
	var step = rand_range(10, 40)
	
	var tile_in_map = in_map()
	if tile_in_map == 40 or tile_in_map == -1:
		walk_state = 0
		if $sprite.flip_h:
			if step:
				velocity.x = -step
				walk_state = 1
			else:
				velocity.x = step
				walk_state = 1
	
	if walk_state == 1:
		if $sprite.flip_h:
			velocity.x = -step
		else:
			velocity.x = step
	else:
		velocity.x = 0
		#$animation.play("idle")
	
	velocity = move_and_slide(velocity)
	
	if velocity.length() > 0:
		$animation.play("run")
	elif velocity.length() == 0:
		$animation.play("idle")

func _save():
	#enemy прячется
	if !save:
		$area2d/area_collision.set_deferred("disabled", true)
		$collision.set_deferred("disabled", true)
		position.y -= 5
		$sprite.self_modulate = Color("#393939")
		$sprite/head.self_modulate = Color("#393939")
		save = true
		#set_physics_process(false)
	elif save:
		$area2d/area_collision.set_deferred("disabled", false)
		$collision.set_deferred("disabled", false)
		position.y += 5
		$sprite.self_modulate = Color("#ffffff")
		$sprite/head.self_modulate = Color("#ffffff")
		save = false
		#set_physics_process(true)
	
func _spawn_props():
	#после смерти спавним патроны в "props"
	var ammo = Ammo.instance()
	ammo.set_position(global_position)
	props.call_deferred("add_child", ammo)

func _on_timer_timeout():
	shooting = not shooting
	if $atention.visible:
		_save()

func _rotation():
	#enemy смотрит то в одну, то в другую сторону
	$sprite.flip_h = not $sprite.flip_h
	$sprite/head.flip_h = not $sprite/head.flip_h
	$raycast.rotation += PI

	#$pos для спавна пули - стрельба
	if $pos.position.x == 7:
		$pos.position.x = -7
	else:
		$pos.position.x = 7

func _on_dir_timer_timeout():
	#если не видим игрока, то смотрим в другую сторону
	if not $atention.visible:
		_rotation()
		
		#вносим разноообрази во время, за которое enemy 
		#поворачивается в другую сторону
		$timer.wait_time = rand_range(2, 3)
	else:
		$timer.wait_time = rand_range(0.7, 1.4)

func _on_VisibilityNotifier2D_screen_entered():
	set_physics_process(true)

func _on_rebirth_timeout():
	hard = true
	var idx = get_instance_id()
	get_node("../../../enemys").spawn_enemy(idx, hard)
	queue_free()

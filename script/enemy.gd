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

onready var props = get_node("../../props")

#export (int) var speed = 2000
var velocity = Vector2.ZERO

func _on_area2d_area_entered(area):
	if area.enemy == true:
		return
		
	if area.name == "bullet":
		die()
		
func shoot() -> void:
	if shooting == false and died == false:
		$timer.start()
		var bullet = Bullet.instance()
		get_parent().add_child(bullet)
		
		var rot = get_rotation()
		if $sprite.flip_h:
			rot += PI
		
		bullet.start($pos.global_position, rot)
		#emit_signal("shoot")
		
func die():
	died = true
	$"../../ui".kills()
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
		
		if pos.distance_to(self.global_position) < 25:
			too_close = true
		else:
			too_close = false
		
		$atention.visible = true
		if !save:
			yield(get_tree().create_timer(0.5), "timeout")
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
	
	var step = rand_range(20, 40)
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
		#$collision.set_deferred("disabled", true)
		position.y -= 5
		$sprite.self_modulate = Color("#393939")
		$sprite/head.self_modulate = Color("#393939")
		save = true
		#set_physics_process(false)
	elif save:
		$area2d/area_collision.set_deferred("disabled", false)
		#$collision.set_deferred("disabled", false)
		position.y += 5
		$sprite.self_modulate = Color("#ffffff")
		$sprite/head.self_modulate = Color("#ffffff")
		save = false
		#set_physics_process(true)
	
func _spawn_props():
	#после смерти спавним патроны
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
	var idx = get_instance_id()
	get_parent().spawn_enemy(idx)
	queue_free()

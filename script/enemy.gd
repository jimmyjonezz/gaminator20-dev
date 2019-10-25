extends KinematicBody2D

export var Ammo : PackedScene
export var Bullet: PackedScene
var shooting = false
var save = false

onready var props = get_node("../../props")

#export (int) var speed = 2000
var velocity = Vector2.ZERO

func _on_area2d_area_entered(area):
	if area.enemy == true:
		return
		
	if area.name == "bullet":
		die()
		
func shoot() -> void:
	if shooting == false:
		$timer.start()
		var bullet = Bullet.instance()
		get_parent().add_child(bullet)
		
		var rot = get_rotation()
		if $sprite.flip_h:
			rot += PI
		
		bullet.start($pos.global_position, rot)
		#emit_signal("shoot")
		
func die():
	$raycast.enabled = false
	$timer.stop()
	$collision.set_deferred("disabled", true)
	$area2d/area_collision.set_deferred("disabled", true)
	$animation.play("die")
	#yield($animation, "animation_finished")
	$dir_timer.stop()
	_spawn_props()
	#queue_free()
	
func _ready():
	randomize()
	#случайное значение шкалы времени для анимации idle
	$animation.seek(rand_range(0, 0.6))
	#время задержки при смене направления flip_h
	$dir_timer.wait_time = rand_range(3, 5)
	$timer.start()
	$dir_timer.start()
	
func _process(delta):
	#луч рэйкаста чего-то касается?
	var target_dis = $raycast.is_colliding()
	#если да, то флаг активен и можно стрелять
	if target_dis:
		$atention.visible = true
		if !save:
			yield(get_tree().create_timer(0.5), "timeout")
			shoot()
		shooting = true
	else:
		$atention.visible = false

func _physics_process(delta):	
	#задел на хождение enemy
	#velocity.x = speed
	velocity = move_and_slide(velocity * delta)
	if velocity.length() > 0:
		$animation.play("idle")
		
func _save():
	#enemy прячется
	if !save:
		position.y -= 5
		$sprite.self_modulate = Color("#393939")
		save = true
		#set_physics_process(false)
	elif save:
		position.y += 5
		$sprite.self_modulate = Color("#ffffff")
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

func _on_dir_timer_timeout():
	#если не видим игрока, то смотрим в другую сторону
	if not $atention.visible:
		$sprite.flip_h = not $sprite.flip_h
		$raycast.rotation += PI
	
		#$pos для спавна пули - стрельба
		if $pos.position.x == 7:
			$pos.position.x = -7
		else:
			$pos.position.x = 7
		
		#вносим разноообрази во время, за которое enemy 
		#поворачивается в другую сторону
		$timer.wait_time = rand_range(2, 3)
	else:
		$timer.wait_time = rand_range(0.7, 1.4)

func _on_VisibilityNotifier2D_screen_entered():
	set_physics_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_physics_process(false)

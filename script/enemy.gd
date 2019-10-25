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
	$atention.visible = false
	$timer.stop()
	$collision.set_deferred("disabled", true)
	$animation.play("die")
	yield($animation, "animation_finished")
	_spawn_props()
	queue_free()
	
func _ready():
	randomize()
	$animation.seek(rand_range(0, 0.6))
	$dir_timer.wait_time = rand_range(1, 6)
	$timer.start()
	$dir_timer.start()
	
func _physics_process(delta):
	var target_dis = $raycast.is_colliding()
	if target_dis:
		$atention.visible = true
		shoot()
		shooting = true
	else:
		$atention.visible = false
	
	#velocity.x = speed
	velocity = move_and_slide(velocity * delta)
	if velocity.length() > 0:
		$animation.play("idle")
		
func _save():
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
	var ammo = Ammo.instance()
	ammo.set_position(global_position)
	props.call_deferred("add_child", ammo)

func _on_timer_timeout():
	shooting = not shooting

func _on_dir_timer_timeout():
	if not $atention.visible:
		$sprite.flip_h = not $sprite.flip_h
		$raycast.rotation += PI
	
		if $pos.position.x == 7:
			$pos.position.x = -7
		else:
			$pos.position.x = 7
		$timer.wait_time = rand_range(1, 4)
		
	if $atention.visible:
		_save()

func _on_VisibilityNotifier2D_screen_entered():
	set_physics_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_physics_process(false)

extends KinematicBody2D

signal shoot()
signal change_ammo()
signal change_health()
signal pickup()

var nums = [7, 8, 9, 10, 11, 12]

export var Bullet : PackedScene

export (int) var speed = 3600
export var look_direction = Vector2(1, 0)

var direction setget set_dir

var velocity = Vector2.ZERO
var shooting = true as bool
#var direction = 0
var count = 4
var health_count = 5
var area_position = Vector2.ZERO
var teleports
var state_machine
var save = false as bool
var move = true

func set_dir(value : int):
	if value != 0:
		direction = value

func _ready():
	randomize()
	$head.frame = nums[randi() % nums.size()]
	direction = 0
	teleports = get_node("../teleport").get_children()
	state_machine = $animtree.get("parameters/playback")
	
func knockback(area):
	var knock = Vector2.ZERO
	var new_vector = Vector2.ZERO
	
	knock = (transform.origin - area.transform.origin) * 2.5
	new_vector = transform.origin + knock
	$tween.interpolate_property(self, "position:x", transform.origin.x, new_vector.x, 0.1, $tween.TRANS_LINEAR, $tween.EASE_OUT_IN)
	$tween.start()
	health_count -= 1
	emit_signal("change_health")

func _physics_process(delta):
	get_input(delta)
	
func _input(event):
	if event.is_action_pressed("enter"):
		if direction != 0:
			move = false
			$pivot/offset.position.x = 0
			state_machine.travel("fade_out")
			$animation.play("fade_out")
			yield($animation, "animation_finished")
			position.y = area_position.y
			state_machine.travel("fade_in")
			$animation.play("fade_in")
			yield($animation, "animation_finished")
			move = not move
			return
		
		if !save:
			position.y -= 5
			$sprite.self_modulate = Color("#393939")
			$head.self_modulate = Color("#393939")
			$player/collisionarea.set_deferred("disabled", true)
			#$collision.set_deferred("disabled", true)
			save = true
			state_machine.travel("idle")
			set_physics_process(false)
		elif save:
			position.y += 5
			$sprite.self_modulate = Color("#ffffff")
			$head.self_modulate = Color("#ffffff")
			$player/collisionarea.set_deferred("disabled", false)
			#$collision.set_deferred("disabled", false)
			save = false
			set_physics_process(true)

func get_input(delta):
	if Input.is_action_just_pressed("fire"):
		if shooting:
			shoot()
		
	if Input.is_action_pressed("ui_right") and move:
		velocity.x += speed
		$sprite.flip_h = false
		$head.flip_h = false
		$pivot/offset.position.x = 60
		$pos.position.x = 7
		look_direction = Vector2(1, 0)
	elif Input.is_action_pressed("ui_left") and move:
		velocity.x -= speed
		$sprite.flip_h = true
		$head.flip_h = true
		$pivot/offset.position.x = 60
		$pos.position.x = -7
		look_direction = Vector2(-1, 0)
	else:
		velocity = Vector2.ZERO
		#state_machine.travel("idle")
	
	if velocity.length() > 0:
		#state_machine.travel("run")
		$animation.play("run")
		
	elif velocity.length() == 0:
		$animation.play("idle")
		#$audio.stop()
		
	#emit_signal("moved")
		
	velocity = move_and_slide(velocity * delta)

func shoot() -> void:
	if count > 0:
		shooting = false
		$timer.start()
		var bullet = Bullet.instance()
		get_parent().add_child(bullet)
		
		var rot = get_rotation()
		if $sprite.flip_h:
			rot += PI
		
		bullet.start($pos.global_position, rot)
		emit_signal("shoot")

func _on_timer_timeout():
	shooting = true

func _on_area2d_area_entered(area):
	if area in teleports:
		area_position.y = area.position.y
		
	if area.is_in_group("health") and health_count < 5:
		health_count = 5
		emit_signal("pickup")
		area.die()
	
	if area.is_in_group("props") and count < 4:
		count = 4
		emit_signal("change_ammo")
		area.die()
	
	if area.is_in_group("bullet"):
		health_count -= 1
		#$pivot/offset/camera/screenshake.start(0.2, 12.0, 12, 0)
		emit_signal("change_health")
		area.die()
		var knock = (transform.origin - area.transform.origin) * 2
		var new_vector = transform.origin + knock
		$tween.interpolate_property(self, "position:x", transform.origin.x, new_vector.x, 0.1, $tween.TRANS_LINEAR, $tween.EASE_OUT_IN)
		$tween.start()
		
	if area.is_in_group("activate"):
		$press.visible = true
		yield(get_tree().create_timer(1), "timeout")
		$press.visible = false

func _on_ui_shooting(signal_state, value):
	if value:
		count = signal_state

func _on_area2d_area_exited(area):
	if area in teleports:
		direction = 0

func _on_player_body_entered(body):
	if body.is_in_group("enemy"):
		knockback(body)

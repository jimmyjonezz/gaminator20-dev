extends Area2D

var speed = 250
var enemy = false

func _ready():
	$shoot.play()
	if get_parent().name == "enemy":
		_layer_off()
	else:
		speed = 350

func start(pos, dir) -> void:
	rotation = dir
	position = pos

func _on_VisibilityNotifier2D_screen_exited():
	die()
	
func _physics_process(delta):
	position += Vector2(speed, 0).rotated(rotation) * delta
	
func die():
	$die.play()
	yield($die, "finished")
	queue_free()

func _on_bullet_area_entered(area):
	if area.is_in_group("enemy"):
		die()

func _on_timer_timeout():
	die()
	
func _layer_off():
	enemy = true

func _on_bullet_body_entered(body):
	if body.is_in_group("wall"):
		die()

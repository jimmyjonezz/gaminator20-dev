extends Area2D

func _ready():
	$anim.play("ammo")
	
func die():
	$pickup.play()
	yield($pickup, "finished")
	queue_free()

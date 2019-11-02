extends Area2D

func _ready():
	$animation.play("idle")
	
func die():
	$pickup.play()
	yield($pickup, "finished")
	queue_free()

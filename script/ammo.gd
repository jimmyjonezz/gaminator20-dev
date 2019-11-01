extends Area2D

func _ready():
	$animation.play("idle")
	
func die():
	$pickup.play()
	yield($pickup, "finished")
	queue_free()

func _on_ammo_area_entered(area):
	if area.name == "player":
		die()

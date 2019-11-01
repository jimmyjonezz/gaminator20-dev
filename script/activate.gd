extends Area2D

signal activate()

func _ready():
	$animation.play("new")
	
func die():
	$pickup.play()
	yield($pickup, "finished")
	queue_free()

func _on_activate_area_entered(area):
	if area.name == "player":
		emit_signal("activate")
		die()

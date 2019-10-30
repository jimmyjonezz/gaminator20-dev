extends Area2D

signal pickup()

func _ready():
	$anim.play("ammo")
	
func die():
	queue_free()

func _on_health_area_entered(area):
	if area.name == "player":
		emit_signal("pickup")
		die()

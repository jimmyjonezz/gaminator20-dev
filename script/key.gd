extends Area2D

signal pickup()

func _on_key_area_entered(area):
	if area.name == "player":
		emit_signal("pickup")
		$pickup.play()
		yield($pickup, "finished")
		queue_free()

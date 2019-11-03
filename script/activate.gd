extends Area2D

signal activate()

enum var_shader {one = 0, two = 1, three = 2, four = 4, 
		five = 5, six = 6, seven = 7, eight = 8}
export (var_shader) var shader
	
func die():
	$sprite.visible = false
	$pickup.play()
	yield($pickup, "finished")
	queue_free()

func _on_activate_area_entered(area):
	if area.name == "player":
		emit_signal("activate", shader)
		die()

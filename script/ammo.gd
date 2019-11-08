extends Area2D

func _ready():
	$animation.play("idle")
	$die.start()
	
func die():
	$pickup.play()
	yield($pickup, "finished")
	queue_free()

func _on_die_timeout():
	queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)

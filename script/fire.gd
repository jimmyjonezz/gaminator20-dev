extends Node2D

func _ready():
	randomize()
	$animation.seek(rand_range(0, 0.6))

func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)

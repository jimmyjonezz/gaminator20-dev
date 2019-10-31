extends Node

var amplitude = 0
var priority = 0

onready var camera = get_parent()

func start(duration = 0.2, freg = 15.0, amplitude = 16, priority = 0):
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude
		
		$duration.wait_time = duration
		$timer.wait_time = 1 / freg
		$duration.start()
		$timer.start()
	
		_shake()

func _shake():
	var rand = Vector2.ZERO
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	$tween.interpolate_property(camera, "offset", camera.offset, rand, 
			$timer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()
	
func _reset():
	$tween.interpolate_property(camera, "offset", camera.offset, Vector2(), 
			$timer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()
	
	priority = 0

func _on_timer_timeout():
	_shake()

func _on_duration_timeout():
	_reset()
	$timer.stop()

extends Position2D

onready var parent = $".."

func _update_pivot():
	rotation = parent.look_direction.angle()

func _ready():
	_update_pivot()
	
func _process(delta):
	_update_pivot()

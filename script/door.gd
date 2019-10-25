extends Area2D

enum var_direction {up = 48, down = -48}
export (var_direction) var direction

func _ready():
	$collision.position.y -= direction
	$sprite.position.y -= direction

func _on_door_body_entered(body):
	var value = direction
	if body.name == "player":
		$sprite.visible = true
		body.direction = value

func _on_door_body_exited(body):
	if body.name == "player":
		$sprite.visible = false

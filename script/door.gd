extends Area2D

enum var_direction {up = 48, down = -48, center = 0}
enum door_sprite {up = 98, down = 82, close = 118}
export (var_direction) var direction

func _ready():
	if direction != 0:
		$collision.position.y -= direction
		$sprite.position.y -= direction
		if direction == 48:
			$door.frame = door_sprite.up
		elif direction == -48:
			$door.frame = door_sprite.down
	elif direction == 0:
		$door.frame = door_sprite.close
		$collision.set_deferred("disabled", false)

func _on_door_body_entered(body):
	var value = direction
	if body.name == "player":
		if direction == 0:
			print("win")
			return
		
		$sprite.visible = true
		body.direction = value

func _on_door_body_exited(body):
	if body.name == "player":
		$sprite.visible = false

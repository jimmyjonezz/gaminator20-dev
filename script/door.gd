extends Area2D

signal win()

enum var_direction {up = 48, down = -48, center = 0, zero = 1}
enum door_sprite {up = 98, down = 82, close = 134, dark_door = 131}
export (var_direction) var direction

var entered = true

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
		
	if direction == 1:
		$door.frame = door_sprite.dark_door
		$collision.set_deferred("disabled", false)

func _on_door_body_entered(body):
	if entered and direction == 1:
		return
	
	var value = direction
	if body.name == "player":
		if direction == 0:
			emit_signal("win")
			return
		
		$sprite.visible = true
		body.direction = value

func _on_door_body_exited(body):
	if body.name == "player":
		$sprite.visible = false

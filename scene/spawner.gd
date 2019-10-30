extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var amount = 3
var enemy = preload("res://scene/enemy.tscn")
onready var parent = self.get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_spawner_body_entered(body):
	if amount > 0 and body.name == "player":
		var e = enemy.instance()
		e.set_position( global_position - Vector2(0, 8) )
		parent.call_deferred("add_child", e)
		amount -= 1

extends Node2D

const ENEMY_SCENE = preload("res://scene/enemy.tscn")
var positions = []

#спавн врагов после смерти
func spawn_enemy(value):
	positions.clear()
	var childs = get_children()
	for x in childs:
		positions.push_back(x)
		
	var new_enemy = ENEMY_SCENE.instance()
	new_enemy.set_name("enemy" + str(get_instance_id()))
	for x in positions:
		if x.get_instance_id() == value:
			add_child(new_enemy)
			new_enemy.position = x.position

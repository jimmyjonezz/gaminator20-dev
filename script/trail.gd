extends Node2D

export var MAX_LENGTH = 20
export var THICKNESS = 1.1

var points = []
var frame = 0

func _physics_process(delta):
	if frame % 3 == 0:
		points.push_front(global_position)
		if points.size() > MAX_LENGTH:
			points.pop_back()
			
	frame += 1
	
	update()
	
func _draw():
	if points.size() < 2:
		return
		
	var antialias = false
	var c = modulate
	var s = float(points.size())
	var adjusted = PoolVector2Array()
	var colors = PoolColorArray()
	
	for i in range(s):
		adjusted.append(points[i] - global_position)
		c.a = lerp(0.5, 0.0, i/s)
		colors.append(c)
		
	draw_set_transform(Vector2(0,0), -get_parent().rotation, Vector2(1,1))
	draw_polyline_colors(adjusted, colors, THICKNESS, antialias)

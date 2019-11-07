extends Area2D

var speed = 250
var enemy = false

func _ready():
	$shoot.play()
	#в этом случаем смотрим кто родитель пули
	#если нода ysort (контейнер enemys), то вырубаем слой
	if get_parent().name == "ysort":
		_layer_off()
	else:
		speed = 350

func die():
	queue_free()

func start(pos, dir) -> void:
	rotation = dir
	position = pos

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func _physics_process(delta):
	position += Vector2(speed, 0).rotated(rotation) * delta

func _on_bullet_area_entered(area):
	if area.is_in_group("enemy") and !enemy:
		queue_free()
	
func _layer_off():
	enemy = true

func _on_bullet_body_entered(body):
	if body.is_in_group("wall"):
		queue_free()

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()

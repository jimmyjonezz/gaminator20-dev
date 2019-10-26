extends CanvasLayer

signal shooting()

var ammo_count = 4
var count = 4
var health_count = 5

func _ready():
	$esc.visible = false
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		$esc.visible = new_pause_state
	
#общая функция для анимации шкалы задержки выстрела, статус баров жизни и патрон
func animate_value(object, start, end, tic):
	$tween.interpolate_property(object, "value", start, end, tic, $tween.EASE_IN, $tween.EASE_OUT)
	$tween.start()

#ловим сигнал shoot с объекта $player
func _on_player_shoot():
	if ammo_count > 0:
		count = ammo_count - 1
		animate_value($margin/vbox/shooting, 0, 16, 0.7)
		animate_value($margin/hbox_left/ammo/ammo_progress, ammo_count, count, 0.8)
		ammo_count = count
		
		emit_signal("shooting", ammo_count)

func _on_player_change_ammo():
	ammo_count = 4
	animate_value($margin/hbox_left/ammo/ammo_progress, count, ammo_count, 0.7)

func _on_player_change_health():
	count = health_count
	health_count -=1
	animate_value($margin/hbox_right/health/health_progress, count, health_count, 0.3)

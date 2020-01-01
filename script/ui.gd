extends CanvasLayer

signal shooting()

var kills_count
var shaders_count = 0
var ammo_count = 4
var count = 4
var health_count = 5
var win = false
var over = false
var timer = 26

onready var shader = get_node("../shaders/control").get_children()
onready var fps = get_node("fps")
onready var shader_time = get_node("shader_time")
var shader_array : Array

func _ready():
	kills_count = 0
	$kills.text = "KILLS: %05d" % [kills_count]
	for x in shader:
		if x as TextureRect:
			shader_array.push_back(x)
	
	randomize()
	$esc.visible = false
	$winner.visible = false
	
func kills():
	kills_count += 1
	$kills.text = "KILLS: %05d" % [kills_count]
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if win or over:
			return
			
		$pause.play()
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		$esc.visible = new_pause_state
		
	if event.is_action_pressed("ui_accept"):
		if get_tree().paused:
			get_tree().set_pause(false)
			get_tree().reload_current_scene()
			$winner.visible = false
			$esc.visible = false
		
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
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
	animate_value($margin/hbox_left/health/health_progress, count, health_count, 0.3)
	yield($tween, "tween_completed")
	
	if count < 2:
		#здесь бы анимацию смерти!
		player_die()
		
func player_die():
	$lose.play()
	over = true
	$winner/winner_text.text = "GAME OVER"
	get_tree().paused = true
	$winner.visible = true

func _on_door_win():
	win = true
	$winner/winner_text.text = "WINNER"
	get_tree().paused = true
	$winner.visible = true

func _on_activate_activate(value):
	shaders_count += 1
	$shaders.text = "%s/8" % shaders_count
	shader_time.stop()
	for x in shader_array.size():
		shader_array[x].visible = false
	
	var m = shader_array[value]
	m.visible = true
	shader_time.start()
	$timer.visible = true

func _process(delta):
	if $timer.visible:
		timer -= delta
		$timer.text = "0:%02d"% round(timer)
	fps.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_player_pickup():
	var health = health_count
	health_count = 5
	animate_value($margin/hbox_right/health/health_progress, health, health_count, 0.7)

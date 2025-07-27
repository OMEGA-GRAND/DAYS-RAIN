extends Control

@onready var shade = %CircleShadow
@onready var menu = %Menu
@onready var parts = [{4 : $Menu/Corner2}]
@onready var IcH = %IconHolder
var start
var key
var k = 1.0
var shake: float 
var t: float
var char_on_attention : bool
var char_on_busy : bool
var char_on_chase : bool
var ssstart = ColorRect.new()

func _ready():
	var playsound = AudioStreamPlayer.new()
	var soud = AudioStreamMP3.new()
	var file = FileAccess.open("res://sounds/enter_game.mp3", FileAccess.READ)
	soud.data = file.get_buffer(file.get_length())
	playsound.stream = soud
	add_child(playsound)
	if find_child("ShadowOnStart") != null:
		start = find_child("ShadowOnStart")
		pass
	else:
		var sh = "res://menu/shaders/start.gdshader"
		ssstart.material.set_shader(sh)
		add_child(ssstart)
		ssstart.name = "ShadowOnStart"
		start = ssstart
	shade.visible = false
	menu.visible = false
	playsound.play()
	await get_tree().create_timer(13.).timeout
	playsound.free()
	pass


func _process(_delta):
	t = clampf(t, 0., 1.)
	shake = clampf(shake, 0., 20.)
	if DisplayServer.window_get_size() != key:
		_on_window_size_changed()
	

	
	if shade.material.get_shader_parameter("value") <= 0.1:
		shade.visible = false
		menu.visible = false
		t += _delta
		if t >= 1.:
			t = 0.
			shake -= 1.
	else:
		shade.visible = true
		menu.visible = true
		menu.position = GlobalParam.center + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
		print("Нода: ", $Menu/Corner2.name, "			Данные позиций: ", $Menu/Corner2.pos, " ,", $Menu/Corner2.Gpos, " ,", $Menu/Corner2.anchors)
		print("Нода: ", $Menu/Line.name, "				Данные позиций: ", $Menu/Line.pos, " ,", $Menu/Line.Gpos, " ,", $Menu/Line.anchors)
		print("Нода: ", $Menu/Line/Ornament_anchor.name, "	Данные позиций: ", $Menu/Line/Ornament_anchor.pos, " ,", $Menu/Line/Ornament_anchor.Gpos)
		t += _delta
		if t >= 1.:
			t = 0.
			shake += 0.2
		if Input.is_action_just_pressed("up_mid_mouse"):
			shake += 0.5
		if Input.is_action_just_pressed("down_mid_nouse"):
			shake -= 0.5

func _on_window_size_changed():
	key = Vector2i(size)

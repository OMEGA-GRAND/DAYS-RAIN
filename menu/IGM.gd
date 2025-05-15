extends Control

@onready var shade = %CircleShadow
@onready var menu = %Menu
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
	if find_child("ShadowOnStart") != null:
		start = find_child("ShadowOnStart")
		pass
	else:
		var sh = "res://menu/start.gdshader"
		ssstart.material.set_shader(sh)
		add_child(ssstart)
		ssstart.name = "ShadowOnStart"
		start = ssstart
	shade.visible = false
	menu.visible = false
	pass


func _process(_delta):
	t = clampf(t, 0., 1.)
	shake = clampf(shake, 0., 20.)
	if DisplayServer.window_get_size() != key:
		_on_window_size_changed()
	k = lerp(k, 0.0, _delta)
	start.material.set_shader_parameter("value", k)
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
		t += _delta
		if t >= 1.:
			t = 0.
			shake += 0.2
		if Input.is_action_just_pressed("up_mid_mouse"):
			shake += 0.5
		if Input.is_action_just_pressed("down_mid_nouse"):
			shake -= 0.5
		
		
		
 
func _on_window_size_changed():
	start.size = DisplayServer.window_get_size()
	key = Vector2i(size)
	start.position = shade.position

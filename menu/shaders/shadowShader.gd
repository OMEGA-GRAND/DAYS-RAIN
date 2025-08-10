extends ColorRect
var key
var k = 0.0
var kk = false
var shaker
signal side_mouse_2nd

func _ready() -> void:
	$"..".connect("shshake", signals)

func signals(data):
	if data is Array:
		if data[0] == "shake":
			shaker = data[1]

func _process(_delta):
	size = DisplayServer.window_get_size()
	if Input.is_action_just_pressed("2nd_side_mouse") or Input.is_action_just_pressed("Э"):
		if kk == false:
			side_mouse_2nd.emit(true)
			kk = true
		else:
			side_mouse_2nd.emit(false)
			kk = false
	if kk == true:
		material.set_shader_parameter("value", k)
		k = lerp(k, lerp(1., .2, shaker / 100), _delta + lerp(.0, 3.0, _delta))
	else:
		material.set_shader_parameter("value", k)
		k = lerp(k, 0.0, _delta + lerp(.0, 8.0, _delta))
	if DisplayServer.window_get_size() != key:
		_on_window_size_changed()
 
func _on_window_size_changed():
	size = DisplayServer.window_get_size()
	key = Vector2i(size)
	position = $"../../Cam".position - (size / 2)

extends Node2D
var FPS = ((func(): if DisplayServer.screen_get_refresh_rate() == -1: return 60 else: return DisplayServer.screen_get_refresh_rate()).call())
var mFPS = FPS / 4
var debug_control = Control.new()
var debug_label = Label.new()
var window_size


func _ready():
	add_child(debug_control)
	debug_control.add_child(debug_label)
	debug_control.set_as_top_level(true)
func _process(_delta):
	if get_viewport().get_camera_3d():
		window_size = Vector2(get_viewport_transform()[0].x, get_viewport_transform()[1].y) + get_viewport_rect().size / 100
	if get_viewport().get_camera_2d():
		window_size = get_viewport().get_camera_2d().position - (get_viewport().get_camera_2d().get_viewport_rect().size / 2.05)
	debug_label.text = str("Текущий MAXFPS[", Engine.max_fps ,"]   Уст.MAXFPS[", FPS, "]   MINFPS[", mFPS, "]   Ваш текущий FPS[", Engine.get_frames_per_second(),"]")
	Engine.max_fps = FPS
	debug_control.position = window_size

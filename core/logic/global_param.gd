extends Node2D
var FPS = ((func(): if DisplayServer.screen_get_refresh_rate() == -1: return 60 else: return DisplayServer.screen_get_refresh_rate()).call())
var mFPS = FPS / 4
var debug_control = Control.new()
var debug_label = Label.new()
var start_label = RichTextLabel.new()
var window_size
var leftUPcorner
var center
var kk := false
var k := false



func _ready():
	add_child(debug_control)
	debug_control.add_child(debug_label)
	debug_control.set_as_top_level(true)
	add_child(start_label)
	start_label.set_as_top_level(true)
	ProjectSettings.set_as_basic("network/limits/debugger/max_chars_per_second", true)
	print(ProjectSettings.get_setting("network/limits/debugger/max_chars_per_second"))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
func _process(_delta):
	Engine.max_fps = FPS
	if get_viewport().get_camera_3d():
		center = Vector2(get_viewport_transform()[0].x, get_viewport_transform()[1].y)
		window_size = center + get_viewport_rect().size / 2
		leftUPcorner = center + get_viewport_rect().size / 100
		
	if get_viewport().get_camera_2d():
		center = get_viewport().get_camera_2d().position 
		window_size = center - (get_viewport().get_camera_2d().get_viewport_rect().size / 2)
		leftUPcorner = center - (get_viewport().get_camera_2d().get_viewport_rect().size / 2.08)
	
	
	
	if k == false:
		start_label.position = leftUPcorner
		start_label.size = Vector2i(1000, 1000)
		start_label.bbcode_enabled = true
		start_label.set_text(str("""Для открытия и закрытия debugmenu нажимай кнопку Shift.
		
		Что бы сэмитировать открытие внутриигрового меню - нажми дальнюю боковую кнопку мыши.
		||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Э".
		
		Что бы запустить генерацию шума - нажми Ctrl.
		||| Генерация шума занимает определённое время, а по достижению 89% проект завсинет - это нормально.
		||| По окончанию генерации на весь экран будет показана картинка. 
		||| Картинку можно будет двигать стрелочками на клавиатуре.
		||| Масштаб картинки можно будет менять на колёсико мыши.
		
		Что бы убрать эту подсказку - открой denugmenu или запусти генерацию.
		[color=green][bgcolor=black]DEBUG: limitOutput: """, ProjectSettings.get_setting("network/limits/debugger/max_chars_per_second"), " V-Sync: ", DisplayServer.window_get_vsync_mode(), " (0=False, 1=True)" ,"[/bgcolor][/color]"))

		if Input.is_action_just_pressed("Shift") or Input.is_action_just_pressed("Ctrl"):
			start_label.queue_free()
			k = true
	if Input.is_action_just_pressed("Shift"):
		if kk == true:
			kk = false
		else:
			kk = true
	if kk == false:
		debug_control.visible = false
	if kk == true:
		debug_label.text = str("Текущий MAXFPS[", Engine.max_fps ,"]   Уст.MAXFPS[", FPS, "]   MINFPS[", mFPS, "]   Ваш текущий FPS[", Engine.get_frames_per_second(),"]")
		debug_control.position = window_size
		debug_control.visible = true
	


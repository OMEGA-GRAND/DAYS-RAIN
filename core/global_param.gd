extends Control

var FPS = round((func(): if DisplayServer.screen_get_refresh_rate() == -1: return 60 else: return DisplayServer.screen_get_refresh_rate()).call()) 
var mFPS = round(FPS / 4)
# Настройки FPS исходя из герцовки монитора или по стандарту.

var goods = [preload("res://hint.png"), NAN]

@onready var glAnchor

var t
# Таймер для перемещения этого синглтона поверх активной(ых) сцен.
var tT 
var tt := 0.0
# Пиздец, что бы как раньше работала дельта для плавного изменения значений в lerp - я делаю эту хуйню-накопитель, пиздец. В синглтонах дельта работает по-другому.

var debug_control = Control.new()
var debug_label = Label.new()
var start_label = RichTextLabel.new()
var cursor_label = Label.new()

var zero_point
var center 
var leftUPcorner
# Переменные для определения координат на экране непосредственно.
# Первая - предполагаемые значения вьюпорта в 2д и 3д среде. Т.е. это размеры зоны отображения действующей камеры в проекте. Работает в процессе.
# Вторая - фактический центр отображаемой области камеры. Работает в процессе.
# Третья - верхний левый угол отображаемой области камеры с небольшим смещением к центру области. Работает в процессе.

@onready var Win = get_window()
var mainWinSize
# Переменная, в которую передаётся размер эжкрана в пикселях.
var screenmode :
	set = screens


var max_resolution = DisplayServer.screen_get_size()
# Размер экрана в пикселях
var resolutions = [Vector2i(1280, 720), Vector2i(1366,768), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(2560,1440), Vector2i(3840,2160), Vector2i(5120,2880)]
# Массив с доступными разрешенимями
var xy_res

var audios

var settings = [0.3, false, [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, DisplayServer.WINDOW_MODE_WINDOWED], false, ]
# Массив настроек, изменять с осторожностью
#0. Чувствительность мыши
#1. Авто-расширение окна игры (да/нет) (отключает и включает переключение размера окна по кнопкам соответсвенно)
#2. Варианты режима окна игры.
#3.

var mouse_sensitivity = [settings[0], settings[0]/100, 0.0]



var a = false
### Включает и выключает режим "чистой" загрузки. Если тут стоит true - отключает настрйоки, дебаг-режим. 
### Не должно влиять на проект, только предоставляет дебаг-режим. Проект не должен зависеть от этой переменной.
### Обязательным является только то что находится выше этой переменной.
### ОБЯЗАТЕЛЬНО оставлять возможность удалить всё связанное с этой переменной.

var kk := false
var k := false
# Для дебаг-меню, переключатели.
# На первую можно ссылаться для открытия дополнительных меню в дебаг-режиме.

var nodes_main = []
# Этот словать используется для проверки наличия нод внутри самого синглтона

const PINS = ["upperNUM1","upperNUM2","upperNUM3","upperNUM4","upperNUM5","upperNUM6","upperNUM7"]

var nodes = []
# Этот словарь должен использоваться для взаимодействия с другими сценами. 
# Опционально можно использовать для редактирования сцен. 
# (имею ввиду удаление, добавление и перемещение нод, их редактирование в процессе работы проекта из этого скрипта)

var stage : String = "InGame"
### Должно использоваться для быстрого переключения между разными состояниями проекта. Возможные значения ниже.
# "InGame" - состояние игры, т.е. запуск игрового мира, генерация ландшавта и так далее.
# Будет дополняться....
#

func screens(mode):
	if mode == 0:
		screenmode = "оконный"
	if mode == 1:
		screenmode = "минимизированный???? Ты как бля его установил????"
	if mode == 2:
		screenmode = "развёрнутый"
	if mode == 3:
		screenmode = "фуллскрин без рамки"
	if mode == 4:
		screenmode = "полноценный фуллскрин"

func nod(xy) -> Vector2i:
	var x = xy.x
	var y = xy.y
	while y != 0:
		var temp = y
		y = x % y
		x = temp
	return Vector2i(xy.x / x, xy.y / x)
	
func _ready():
	if max_resolution <= resolutions[0]:
		settings[1] = false
		DisplayServer.window_set_size(resolutions[0])
		DisplayServer.window_set_mode(settings[2][0])
	xy_res = nod(max_resolution)
	AudioServer.add_bus()
	AudioServer.add_bus()
	AudioServer.generate_bus_layout()
	t = Timer.new()

	t.set_wait_time(1)
	t.set_one_shot(true)
	Win.borderless = true
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	mouse_sensitivity[2] = settings[0]
	Win.set_max_size(max_resolution)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	add_child(debug_control)
	debug_control.add_child(debug_label)
	debug_control.add_child(cursor_label)
	debug_control.set_as_top_level(true)
	add_child(start_label)
	start_label.set_as_top_level(true)
	
	ProjectSettings.set_as_basic("network/limits/debugger/max_chars_per_second", true)

	### Далее подключается исключительно временная, дебаг-логика, для проверки чего-либо. 

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pass

func _process(delta):
	mainWinSize = Win.get_size()
	Win.size.x = clamp(Win.size.x, Win.get_min_size().x, Win.get_max_size().x) 
	Win.size.y = clamp(Win.size.y, Win.get_min_size().y, Win.get_max_size().y) 
	if t.get_time_left() < 0.05:
		t.stop() 
		get_tree().get_root().move_child.call_deferred(self, -1)
	screenmode = DisplayServer.window_get_mode()
	Engine.max_fps = FPS
	if Input.is_action_just_pressed("Q") or Input.is_action_just_pressed("1st_side_mouse"):
		if DisplayServer.window_get_mode() == settings[2][2]:
			DisplayServer.window_set_mode(settings[2][0])
		else:
			DisplayServer.window_set_mode(settings[2][2])
	if get_tree().get_root().get_child(0).name == "GlobalParam":
		zero_point = Vector2.ZERO
		center = Vector2.ZERO
		leftUPcorner = Vector2.ZERO 
	if get_tree().get_root().get_child(0) as Node3D and get_viewport().get_camera_3d():
		zero_point = Vector2(get_viewport_rect().position)
		center = Vector2(zero_point + (get_viewport_rect().size / 2))
		leftUPcorner = Vector2(zero_point - (get_viewport_rect().size / 2))
	if get_tree().get_root().get_child(0) as Node2D and get_viewport().get_camera_2d():
		glAnchor = get_viewport().get_camera_2d().position
		zero_point = glAnchor - Vector2(get_viewport().get_camera_2d().get_viewport_rect().size / 2)
		center = glAnchor
		leftUPcorner = zero_point
	if mainWinSize <= max_resolution and screenmode == "оконный":
		DisplayServer.window_set_position((max_resolution / 2) - (mainWinSize / 2))
	
	if true:
		var L
		var Lpos
		if nodes_main.has("hint"):
			L = nodes_main[nodes_main.find("hint") + 1]
			L.hide()
		else:
			nodes_main.append("hint")
			nodes_main.append(TextureRect.new())
			L = nodes_main[nodes_main.find("hint") + 1]
			L.texture = goods[0]
			L.position = zero_point + Vector2(mainWinSize) - Vector2(0, L.texture.get_size().y)
			add_child(L)
			L.name = "hint"
			var i = RichTextLabel.new()
			L.add_child(i)
			i.size = Vector2i(L.texture.get_size())
			i.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			i.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			i.text = "МОЖЕТ ПРОИЗОЙТИ БАГ!"

		if settings[1] == true:
			if mainWinSize < max_resolution and mainWinSize > max_resolution - Vector2i(5,5):
				DisplayServer.window_set_mode(settings[2][0])
			if DisplayServer.window_get_mode() != settings[2][0]:
				if settings[3] == false:
					tT = Timer.new()
					tT.autostart = false
					tT.wait_time = 5
					add_child(tT) 
					tT.start()
					settings[3] = true
				for keys in PINS:
					if Input.is_action_pressed(keys):
						tT.stop()
						tt = 0.
						tT.start()
				if mainWinSize < max_resolution and float(max_resolution.x) / float(resolutions[0].x) - float(mainWinSize.x) / float(resolutions[0].x) <= 0.3 and float(max_resolution.y) / float(resolutions[0].y) - float(mainWinSize.y) / float(resolutions[0].y) <= 0.3:
					tt += delta * lerpf(.0, 15, tt + delta)
					tt = clampf(tt, .0, 1.0)
					L.show()
					Lpos = zero_point + Vector2(mainWinSize) - Vector2(lerp(Vector2(0, L.texture.get_size().y), Vector2(L.texture.get_size()), clampf(tt, .0, 1.0)))
					L.position = Lpos
				else:
					tt -= delta * lerpf(.0, 15, tt + delta)
					tt = clampf(tt, .0, 1.0)
			if DisplayServer.window_get_mode() == settings[2][0]:
				tT.stop()
				settings[3] = true
				tt = .0
			Win.size.x += xy_res.x / lerp(0, 10, clampf(tT.time_left / tT.wait_time, 0.01,1.))
			Win.size.y += xy_res.y / lerp(0, 10, clampf(tT.time_left / tT.wait_time, 0.01,1.))
		
	if a == false:
		if k == false:
			start_label.position = leftUPcorner
			start_label.size = Vector2i(1000, 1000)
			start_label.bbcode_enabled = true
			if nodes.has("startmenu") and nodes.has("newgame") and nodes.has("settings"):
				start_label.set_text(str("""Для открытия и закрытия debugmenu нажимай кнопку Shift. Ctrl и Shift уберут подсказку.
				Для переключения полноэкранного и оконного режима - нажми на ближнюю боковую кнопку мыши.
		||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Й".
		||| Можно менять размер окна на цифры на клавиатуре (сверху, 1-7).
		||| Проект не позволит применить разрешение, выше экранного.
				Вы можете увеличивать частоту ударов.
		||| Для этого покрутите колёсиком мыши в обе стороны)))
				Что бы убрать эту подсказку - открой denugmenu или запусти генерацию.
		[color=green][bgcolor=black]DEBUG: limitOutput: """, ProjectSettings.get_setting("network/limits/debugger/max_chars_per_second"), " V-Sync: ", DisplayServer.window_get_vsync_mode(), " (0=False, 1=True)" ,"[/bgcolor][/color]"))
			if nodes.has("main") and nodes.has("IGM") and nodes.has("character"):
				start_label.set_text(str("""Для открытия и закрытия debugmenu нажимай кнопку Shift. Ctrl и Shift уберут подсказку.
				Для переключения полноэкранного и оконного режима - нажми на ближнюю боковую кнопку мыши.
		||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Й".
		||| Можно менять размер окна на цифры на клавиатуре (сверху, 1-7).
		||| Проект не позволит применить разрешение, выше экранного.
				Что бы сэмитировать открытие внутриигрового меню - нажми дальнюю боковую кнопку мыши.
		||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Э".
		||| Включена симуляция "паники", со временем меню начнёт трястись когда оно открыто.
		||| Увеличивать/уменьшать тряску меню можно прокручивая колесо мыши.
		||| Тряска уменьшается со временем, когда меню закрыто, колесо мыши ничего не делает.
				Что бы запустить генерацию шума - нажми Ctrl [color=black][bgcolor=white](временно отключено, только закроет эту подсказу)[/bgcolor][/color].
		||| Генерация шума занимает определённое время, в зависимости от выбранного разрешения.

				Что бы убрать эту подсказку - открой denugmenu или запусти генерацию.
		[color=green][bgcolor=black]DEBUG: limitOutput: """, ProjectSettings.get_setting("network/limits/debugger/max_chars_per_second"), " V-Sync: ", DisplayServer.window_get_vsync_mode(), " (0=False, 1=True)" ,"[/bgcolor][/color]"))
			if Input.is_action_just_pressed("Shift") or Input.is_action_just_pressed("Ctrl"):
				start_label.hide()
				k = true
		if Input.is_action_just_pressed("Shift"):
			if kk == true:
				kk = false
			else:
				kk = true
		if kk == false:
			debug_control.visible = false
		if kk == true:
			if nodes.has("startmenu") and nodes.has("newgame") and nodes.has("settings"):
				var F = (
					func():
						var FF = nodes[nodes.find("bcg") + 1]
						var FFF : Array
						for i in FF:
							FFF.append(Vector2(snapped(i.get_autoscroll().x, 0.1),snapped(i.get_autoscroll().x, 0.1)))
						return FFF
						).call()
				if Input.is_action_just_pressed("up_mid_mouse"):
					nodes[nodes.find("startmenu") + 1].L[0] += 1.
				if Input.is_action_just_pressed("down_mid_nouse"):
					nodes[nodes.find("startmenu") + 1].L[0] -= 1.
				if nodes[nodes.find("newgame") + 1].k == true:

					cursor_label.text = str("Скорость фона:", F, """
Пульс: """, snappedf(nodes[nodes.find("startmenu") + 1].L[0], 0.01), """
Пульс ускоряется.
Новая игра.""")
				elif nodes[nodes.find("settings") + 1].k == true:
					cursor_label.text = str("Скорость фона:", F, """
Пульс: """, snappedf(nodes[nodes.find("startmenu") + 1].L[0], 0.01), """
Пуль замедляется.
Настройки.""")
				else:
					cursor_label.text = str("Скорость фона:", F, """
Пульс: """, snappedf(nodes[nodes.find("startmenu") + 1].L[0], 0.01), """
Пуль замедляется.""")
			cursor_label.position = get_viewport().get_mouse_position() + Vector2(10,10)
			if settings[1] == true:
				debug_label.text = str("currentmaxFPS[", Engine.max_fps ,"]   maxFPS[", FPS, "]   minFPS[", mFPS, "]   FPS[", Engine.get_frames_per_second(),"""]
Важная инфа: """, "сенса: ", mouse_sensitivity, " Положение мыши: ", get_viewport().get_mouse_position(), """
Режим окна игры: """, screenmode, """
Допустимое разрешение экрана: """, max_resolution, """
Позиция окна на экране: """, DisplayServer.window_get_position(), " Разрешение: ", mainWinSize, " Соотношение экрана: ", xy_res, " Центр: ", -center, " Левый верхний угол, он же нулевая точка: ", leftUPcorner + (-center), """
Стат.: """, tt, """
""",tT.time_left, """
""",tT.wait_time , """
""",clampf(tT.time_left / tT.wait_time, 0.01,1.), """
""", xy_res.x / lerp(0, 10, clampf(tT.time_left / tT.wait_time, 0.01,1.)))
			else:
				debug_label.text = str("currentmaxFPS[", Engine.max_fps ,"]   maxFPS[", FPS, "]   minFPS[", mFPS, "]   FPS[", Engine.get_frames_per_second(),"""]
Важная инфа: """, "сенса: ", mouse_sensitivity, " Положение мыши: ", get_viewport().get_mouse_position(), """
Режим окна игры: """, screenmode, """
Допустимое разрешение экрана: """, max_resolution, """
Позиция окна на экране: """, DisplayServer.window_get_position(), " Разрешение: ", mainWinSize, " Соотношение экрана: ", xy_res, " Центр: ", -center, " Левый верхний угол, он же нулевая точка: ", leftUPcorner + (-center))
			
			debug_control.position = leftUPcorner
			debug_control.visible = true
		if Input.is_action_just_pressed("upperNUM1"):
			if max_resolution > resolutions[0]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[0] / 2))
				DisplayServer.window_set_size(resolutions[0])
			elif max_resolution == resolutions[0]:
				DisplayServer.window_set_size(resolutions[0])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)
		if Input.is_action_just_pressed("upperNUM2"):
			if max_resolution > resolutions[1]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[1] / 2))
				DisplayServer.window_set_size(resolutions[1])
			elif max_resolution == resolutions[1]:
				DisplayServer.window_set_size(resolutions[1])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)
		if Input.is_action_just_pressed("upperNUM3"):
			if max_resolution > resolutions[2]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[2] / 2))
				DisplayServer.window_set_size(resolutions[2])
			elif max_resolution == resolutions[2]:
				DisplayServer.window_set_size(resolutions[2])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)
		if Input.is_action_just_pressed("upperNUM4"):
			if max_resolution > resolutions[3]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[3] / 2))
				DisplayServer.window_set_size(resolutions[3])
			elif max_resolution == resolutions[3]:
				DisplayServer.window_set_size(resolutions[3])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)
		if Input.is_action_just_pressed("upperNUM5"):
			if max_resolution > resolutions[4]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[4] / 2))
				DisplayServer.window_set_size(resolutions[4])
			elif max_resolution == resolutions[4]:
				DisplayServer.window_set_size(resolutions[4])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)
		if Input.is_action_just_pressed("upperNUM6"):
			if max_resolution > resolutions[5]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[5] / 2))
				DisplayServer.window_set_size(resolutions[5])
			elif max_resolution == resolutions[5]:
				DisplayServer.window_set_size(resolutions[5])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)
		if Input.is_action_just_pressed("upperNUM7"):
			if max_resolution > resolutions[6]:
				DisplayServer.window_set_mode(settings[2][2])
				DisplayServer.window_set_position((max_resolution / 2) - (resolutions[6] / 2))
				DisplayServer.window_set_size(resolutions[6])
			elif max_resolution == resolutions[6]:
				DisplayServer.window_set_size(resolutions[6])
				DisplayServer.window_set_mode(settings[2][0])
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", max_resolution)

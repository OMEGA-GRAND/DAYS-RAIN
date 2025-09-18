extends Node2D

var FPS = round(((func(): if DisplayServer.screen_get_refresh_rate() == -1: return 60 else: return DisplayServer.screen_get_refresh_rate()).call())) 
var mFPS = round(FPS / 4)
# Настройки FPS исходя из герцовки монитора или по стандарту.

var debug_control = Control.new()
var debug_label = Label.new()
var start_label = RichTextLabel.new()

var center
var window_size
var leftUPcorner
# Переменные для определения координат на экране непосредственно.
# Первая - предполагаемые значения вьюпорта в 2д и 3д среде. Т.е. это размеры зоны отображения действующей камеры в проекте. Работает в процессе.
# Вторая - фактический центр отображаемой области камеры. Работает в процессе.
# Третья - верхний левый угол отображаемой области камеры с небольшим смещением к центру области. Работает в процессе.

var mainWinSize
# Переменная, в которую передаётся размер эжкрана в пикселях.
var screenmode :
	set = screens

var resolutions = [Vector2i(1280, 720), Vector2i(1366,768), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(2560,1440), Vector2i(3840,2160), Vector2i(5120,2880)]
# Массив с доступными 16:9 разрешенимями

var kk := false
var k := false
# Для дебаг-меню, переключатели.
# На первую можно ссылаться для открытия дополнительных меню в дебаг-режиме.

#@onready var efw : Array = [{"name" : ""}, {"name_property" : ""}, {"typed_value" : null}, {"type_of_math_operatin" : ""}]:
	#set = set_get
#var node
## Глобальная функция set-get. Пока что не рабочая.

var a = true
### Включает и выключает режим "чистой" загрузки. Если тут стоит true - отключает настрйоки, дебаг-режим. 
### Это может сломать некоторую логику, если скрипты в активном дереве сцены обращаются к этому синглтону.

var nodes = []
# Этот словарь должен использоваться для взаимодействия с другими сценами. 
# Опционально можно использовать для редактирования сцен. 
# (имею ввиду удаление, добавление и перемещение нод, их редактирование в процессе работы проекта из этого скрипта)

var settings = [0.3]


var mouse_sensitivity = [settings[0], settings[0]/100, 0.0]

var stage : String = "InGame"
### Должно использоваться для быстрого переключения между разными состояниями проекта. Возможные значения ниже.
# "InGame" - состояние игры, т.е. запуск игрового мира, генерация ландшавта и так далее.
# Будет дополняться....
#
#
#
#
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


func _ready():
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	mouse_sensitivity[2] = settings[0]
	DisplayServer.window_set_min_size(resolutions[0])
	DisplayServer.window_set_max_size(DisplayServer.screen_get_size())
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	add_child(debug_control)
	debug_control.add_child(debug_label)
	debug_control.set_as_top_level(true)
	add_child(start_label)
	start_label.set_as_top_level(true)
	ProjectSettings.set_as_basic("network/limits/debugger/max_chars_per_second", true)
	print(ProjectSettings.get_setting("network/limits/debugger/max_chars_per_second"))
	### Далее подключается исключительно временная, дебаг-логика, для проверки чего-либо. 
	### МЕНЯТЬ ЧТО-ЛИБО ВЫШЕ ЭТИХ СТРОК НЕЛЬЗЯ, СЛОМАЕТЕ ПРОЕКТ!!!

func _process(_delta):
	screenmode = DisplayServer.window_get_mode()
	Engine.max_fps = FPS
	mainWinSize = DisplayServer.window_get_size()
	if Input.is_action_just_pressed("Q") or Input.is_action_just_pressed("1st_side_mouse"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if get_viewport().get_camera_3d():
		center = Vector2(get_viewport_transform()[0].x, get_viewport_transform()[1].y)
		window_size = center + get_viewport_rect().size / 2
		leftUPcorner = center + get_viewport_rect().size / 100
			
	if get_viewport().get_camera_2d():
		center = get_viewport().get_camera_2d().position 
		window_size = center - (get_viewport().get_camera_2d().get_viewport_rect().size / 2)
		leftUPcorner = center - (get_viewport().get_camera_2d().get_viewport_rect().size / 2.08)

	if a == false:
		if k == false:
			start_label.position = leftUPcorner
			start_label.size = Vector2i(1000, 1000)
			start_label.bbcode_enabled = true
			start_label.set_text(str("""Для открытия и закрытия debugmenu нажимай кнопку Shift.
			
	Что бы сэмитировать открытие внутриигрового меню - нажми дальнюю боковую кнопку мыши.
	||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Э".
	||| Включена симуляция "паники", со временем меню начнёт трястись когда оно открыто.
	||| Увеличивать/уменьшать тряску меню можно прокручивая колесо мыши.
	||| Тряска уменьшается со временем, когда меню закрыто, колесо мыши ничего не делает.
	
	Что бы войти полноэкранный и обратно режим - нажми на ближнюю боковую кнопку мыши.
	||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Й".
	||| Можно менять размер окна на цифры на клавиатуре (сверху, 1-7).
	
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
			debug_label.text = str("currentmaxFPS[", Engine.max_fps ,"]   maxFPS[", FPS, "]   minFPS[", mFPS, "]   FPS[", Engine.get_frames_per_second(),"""]
Важная инфа: """, "сенса: ", mouse_sensitivity, """ 
Режим окна игры: """, screenmode)
			debug_control.position = window_size
			debug_control.visible = true
		if Input.is_action_just_pressed("upperNUM1"):
			if DisplayServer.screen_get_size() > resolutions[0]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[0] / 2))
				DisplayServer.window_set_size(resolutions[0])
			elif DisplayServer.screen_get_size() == resolutions[0]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())
		if Input.is_action_just_pressed("upperNUM2"):
			if DisplayServer.screen_get_size() > resolutions[1]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[1] / 2))
				DisplayServer.window_set_size(resolutions[1])
			elif DisplayServer.screen_get_size() == resolutions[1]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())
		if Input.is_action_just_pressed("upperNUM3"):
			if DisplayServer.screen_get_size() > resolutions[2]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[2] / 2))
				DisplayServer.window_set_size(resolutions[2])
			elif DisplayServer.screen_get_size() == resolutions[2]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())
		if Input.is_action_just_pressed("upperNUM4"):
			if DisplayServer.screen_get_size() > resolutions[3]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[3] / 2))
				DisplayServer.window_set_size(resolutions[3])
			elif DisplayServer.screen_get_size() == resolutions[3]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())
		if Input.is_action_just_pressed("upperNUM5"):
			if DisplayServer.screen_get_size() > resolutions[4]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[4] / 2))
				DisplayServer.window_set_size(resolutions[4])
			elif DisplayServer.screen_get_size() == resolutions[4]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())
		if Input.is_action_just_pressed("upperNUM6"):
			if DisplayServer.screen_get_size() > resolutions[5]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[5] / 2))
				DisplayServer.window_set_size(resolutions[5])
			elif DisplayServer.screen_get_size() == resolutions[5]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())
		if Input.is_action_just_pressed("upperNUM7"):
			if DisplayServer.screen_get_size() > resolutions[6]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (resolutions[6] / 2))
				DisplayServer.window_set_size(resolutions[6])
			elif DisplayServer.screen_get_size() == resolutions[6]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				printerr("Вы пытаетесь установить разрешение выше чем допустимо вашим монитором! Максимальное значение в пикселях: ", DisplayServer.screen_get_size())

#func set_get(val : Array):
	#if val.size() == 2:
		#print_rich("Получение значения свойства.... ", val)
		#if val[0] is String:
			#node = get_parent().find_child(val[0])
			#if node == null:
				#printerr("Целевая нода не найдена! ", val)
		#else:
			#printerr("Не верный тип названия ноды. ", val)
		#if val[1] is String and node != null:
			#var memb = node.get_property_list()
			#for l in memb.size():
				#if val[1] in memb[l]["name"]:
					#break
				#else:
					#if node == null:
						#pass
					#else:
						#if l == memb.size() - 1:
							#printerr("Передано несуществующее свойство в ноде: ", node ," , ", val)
		#else:
				#if node == null:
					#pass
				#else:
						#printerr("Не верный тип названия свойства ноды. " , val)
	#if val.size() == 3 or val.size() == 4:
		#print_rich("Установка значения свойства.... ", val)
		#if val[0] is String:
			#node = get_parent().find_child(val[0])
			#if node == null:
				#printerr("Целевая нода не найдена! ", val)
		#else:
			#printerr("Не верный тип названия ноды. ", val)
		#if val[1] is String and node != null:
			#var memb = node.get_property_list()
			#for l in memb.size():
				#if val[1] in memb[l]["name"]:
					#break
				#else:
					#if node == null:
						#pass
					#else:
						#if l == memb.size() - 1:
							#printerr("Передано несуществующее свойство в ноде: ", node ," , ", val)
		#else:
				#if node == null:
					#pass
				#else:
						#printerr("Не верный тип названия свойства ноды. " , val)
		#if (val[2] is String or val[2] is int or val[2] is float or val[2] is bool) and node != null:
			#if typeof(node.get(val[1])) == typeof(val[2]):
				#if val[2] is int or val[2] is float:
					#if val.size() == 4 and val[3] is String:
						#if val[3] == "+": 
							#node.set(val[1], node.get(val[1]) + val[2])
						#if val[3] == "-": 
							#node.set(val[1], node.get(val[1]) - val[2])
						#if val[3] == "*": 
							#node.set(val[1], node.get(val[1]) * val[2])
						#if val[3] == "/":
							#node.set(val[1], node.get(val[1]) / val[2])
					#elif val.size() == 3: 
						#node.set(val[1], val[2])
				#else:
					#node.set(val[1], val[2])
		#else:
				#if node == null:
					#pass
				#else:
					#printerr("Не верный тип передаваемого значения свойства. " , val)
		#pass

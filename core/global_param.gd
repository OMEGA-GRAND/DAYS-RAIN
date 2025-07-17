extends Node2D

var FPS = ((func(): if DisplayServer.screen_get_refresh_rate() == -1: return 60 else: return DisplayServer.screen_get_refresh_rate()).call())
var mFPS = FPS / 4
# Настройки FPS исходя из герцовки монитора или по стандарту.

var debug_control = Control.new()
var debug_label = Label.new()
var start_label = RichTextLabel.new()

var center
var window_size
var leftUPcorner
# Первая - предполагаемые значения вьюпорта в 2д и 3д среде. Т.е. это размеры зоны отображения действующей камеры в проекте. Работает в процессе.
# Вторая - фактический центр отображаемой области камеры. Работает в процессе.
# Третья - верхний левый угол отображаемой области камеры с небольшим смещением к центру области. Работает в процессе.

var kk := false
var k := false
# Для дебаг-меню, переключатели.

var a = false
### Включает и выключает режим "чистой" загрузки. Если тут стоит true - отключает настрйоки, дебаг-режим. 
### Это может сломать некоторую логику, если скрипты в активном дереве сцены обращаются к этому синглтону.

@onready var nodes = {
	"charFile" : preload("res://char.tscn").instantiate() ,
	"needersFole" : preload("res://needers.tscn").instantiate()
	}
# Этот словарь должен использоваться для редактирования текущего дерева сцены. Опционально можно использовать для редактирования сцен. (имею ввиду удаление, добавление и перемещение нод, их редактирование в процессе работы проекта из этого скрипта)

var stage : String = "InGame"
### Должно будет использоваться для быстрого переключения между разными состояниями проекта. Возможные значения ниже.
# "InGame" - состояние игры, т.е. запуск игрового мира, генерация ландшавта и так далее.
# Будет дополняться....
#
#
#
#
#

func _ready():
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
	if a == false:
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
		||| Включена симуляция "паники", со временем меню начнёт трястись когда оно открыто.
		||| Увеличивать/уменьшать тряску меню можно прокручивая колесо мыши.
		||| Тряска уменьшается со временем, когда меню закрыто, колесо мыши ничего не делает.
		
		Что бы войти полноэкранный и обратно режим - нажми на ближнюю боковую кнопку мыши.
		||| Если у тебя на мышке нет боковых кнопок - нажми русскую "Й".
		
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
		
	
	

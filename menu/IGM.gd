extends Control


	## Прежде чем читать дальше этот скприпт:
	# IGM - InGameMenu - Внутриигровое меню. 
	

@onready var shade = %CircleShadow
@onready var menu = %Menu
@onready var IcH = %IconHolder
@onready var one = $Menu/RichTextLabel

@onready var bg = $Menu/background
@onready var Corner1 = [%Corner1, %Corner1.anchors]
@onready var Corner2 = [%Corner2, %Corner2.anchors]
@onready var Corner3 = [%Corner3, %Corner3.anchors]
@onready var Corner4 = [%Corner4, %Corner4.anchors]
@onready var Line1 = [%Line1, %Line1.anchors]
@onready var Line2 = [%Line2, %Line2.anchors]
@onready var Line3 = [%Line3, %Line3.anchors]
@onready var Line4 = [%Line4, %Line4.anchors]
@onready var ornament = preload("res://menu/bones/tscns/ornament.tscn").instantiate()
var countOrnament = []
# Страшно, да?
# А я это постоянно держу в голове. В общем это - переменные для хранения всех частей меню.

var Xsize = Vector2(0.15, 0.15)
##Коэфициент масштаба элементов IGM.



var shake: float 
# Коэфициент тряски. При открытом IGM - постоянно увеличивается, иначе - наоборот. Колесо мыши для ручного изменения.
signal shshake


var t: float
# Таймер, ограниченный от 0 до 1.
var k = 1 
var kk = 0
 
var winSize
# Для проверки размера окна игры.
var tt  = Timer.new()
# Таймер после изменения размера окна игры.
var l : int
# Переключатель для проверки размера окна игры.


var char_on_attention : bool
var char_on_busy : bool
var char_on_chase : bool
## Переменные на будущшее.
#Это режимы. 
#1. Персонаж обнаружен.
#2. Персонаж занят.
#3. Персонаж - жертва идущей прямо сейчас охоты.


var ssstart = ColorRect.new()
# Стартовое затемнение, декоративный элемент. В эту переменную вносится UI объект с шейдером.
var start
# Просто для проверки наличия предыдущего объекта. Лучше не убирать.

var calc
# Для расчёта позиций каждого из элементов меню. 

func _ready():
	
	add_child(tt)
	tt.autostart = false
	tt.one_shot = true
	shade.connect("side_mouse_2nd", leverer)
	menu.modulate.a = 0
	Corner1[0].scale = Xsize
	Corner2[0].scale = Xsize
	Corner3[0].scale = Xsize
	Corner4[0].scale = Xsize
	Line1[0].scale = Xsize
	Line2[0].scale = Xsize
	Line3[0].scale = Xsize
	Line4[0].scale = Xsize
	
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.relative.is_zero_approx() == false:
			menu.position -= event.relative * lerp(GlobalParam.mouse_sensitivity[1] , GlobalParam.mouse_sensitivity[0]*5, shake / 100) 
			bg.position += event.relative * lerp(GlobalParam.mouse_sensitivity[1], GlobalParam.mouse_sensitivity[0]*5, shake / 100)
			pass

func leverer(lever):
	if lever == true:
		kk = 1
	if lever == false:
		kk = 0
	
func _process(delta):
	if tt.time_left == 0:
		tt.stop()
		l = 1
	else:
		l = 0
	if winSize != DisplayServer.window_get_size():
		if tt.time_left == 0 or tt.is_stopped():
			tt.start(3.)
			winSize = DisplayServer.window_get_size()
		else: 
			tt.stop()
			tt.start(3.)
			winSize = DisplayServer.window_get_size()
	
	
	shshake.emit(["shake", shake])
	
	if kk == 1:
		@warning_ignore("integer_division")
		menu.modulate.a = lerp(menu.modulate.a, 1., delta *2)
		
	else:
		@warning_ignore("integer_division")
		menu.modulate.a = lerp(menu.modulate.a, 0., delta *7)
	
	menu.modulate.a = clampf(menu.modulate.a, 0., 2.)
	position = lerp(position, Vector2.ZERO, delta)
	
	
	one.text = str("к.тряски: ", shake, " вкл/выкл: ", k, """
таймер: """, t, """
стат.данные:""", """
в_л угол: """, Corner1[0].position, " я_н: ", round(menu.to_local(Corner1[1][1].global_position)), " я_п: ", round(menu.to_local(Corner1[1][0].global_position)), """
в_п угол: """, Corner2[0].position, " я_л: ", round(menu.to_local(Corner2[1][1].global_position)), " я_н: ", round(menu.to_local(Corner2[1][0].global_position)), """
н_п угол: """, Corner3[0].position, " я_в: ", round(menu.to_local(Corner3[1][1].global_position)), " я_л: ", round(menu.to_local(Corner3[1][0].global_position)), """
н_л угол: """, Corner4[0].position, " я_п: ", round(menu.to_local(Corner4[1][1].global_position)), " я_в: ", round(menu.to_local(Corner4[1][0].global_position)), """
верхняя линия: """, Line1[0].position, """
правая линия: """, Line2[0].position, """
нижняя линия: """, Line3[0].position, """
левая линия: """, Line4[0].position, """
к.масштаба меню: """, Xsize, " t: ", snapped(tt.time_left, 0.1), " menu.size откл/вкл: ", l, """
мин/макс/текущий размеры окна: """, GlobalParam.resolutions[0], "/", DisplayServer.screen_get_size(), "/", DisplayServer.window_get_size())
	
	t = clampf(t, 0., 1.)
	shake = clampf(shake, 0., 100.)
	
	if l == 0:
		calc = Vector2(GlobalParam.mainWinSize / 4)
		Corner1[0].position	 = lerp(Corner1[0].position, -calc, delta *2)
		Corner2[0].position	 = lerp(Corner2[0].position, Vector2(calc.x, -calc.y), delta *2)
		Corner3[0].position	 = lerp(Corner3[0].position, calc, delta *2)
		Corner4[0].position	 = lerp(Corner4[0].position, Vector2(-calc.x, calc.y), delta *2)
		Line1[0].position	 = lerp(Line1[0].position, Vector2(.0 , -calc.y), delta *2)
		Line2[0].position	 = lerp(Line2[0].position, Vector2(calc.x , 0), delta *2)
		Line3[0].position	 = lerp(Line3[0].position, Vector2(.0 , calc.y), delta *2)
		Line4[0].position	 = lerp(Line4[0].position, Vector2(-calc.x , 0), delta *2)
		Line1[0].scale.x = (abs(Corner1[0].position.x) + abs(Corner2[0].position.x) - 127 * 2) / 242
		Line2[0].scale.x = (abs(Corner2[0].position.y) + abs(Corner3[0].position.y) - 127 * 2) / 242
		Line3[0].scale.x = (abs(Corner3[0].position.x) + abs(Corner4[0].position.x) - 127 * 2) / 242
		Line4[0].scale.x = (abs(Corner4[0].position.y) + abs(Corner1[0].position.y) - 127 * 2) / 242
	menu.position = Vector2(
		clamp(menu.position.x ,-Vector2(DisplayServer.window_get_size()).x * 1.5 , Vector2(DisplayServer.window_get_size()).x * 1.5),
		clamp(menu.position.y ,-Vector2(DisplayServer.window_get_size()).y * 1.1 , Vector2(DisplayServer.window_get_size()).y * 1.1)
	)
	bg.position = Vector2(
		clamp(bg.position.x, (Vector2.ZERO.x - bg.size.x / 2) - 10., (Vector2.ZERO.x - bg.size.x / 2) + 10.),
		clamp(bg.position.y, (Vector2.ZERO.y - bg.size.y / 2) - 10., (Vector2.ZERO.y - bg.size.y / 2) + 10.)
		) 
	bg.position = lerp(bg.position, Vector2.ZERO - bg.size / 2, delta * 10)
	bg.size = Vector2(abs(Corner1[0].position.x) + abs(Corner2[0].position.x), abs(Corner1[0].position.y) + abs(Corner3[0].position.y)) - Vector2(40,40)

	if Input.is_action_just_pressed("mid_mouse"):
		if k == 0:
			k = 1
		else:
			k = 0
			
	if shade.material.get_shader_parameter("value") <= 0.1:
		shade.visible = false
		menu.visible = false
		if GlobalParam.kk == false:
			one.visible = false
		if k == 1:
			t += delta
			if t >= 1.:
				t = 0.
				shake -= 5.
		else:
			shake = 0.
			t = 0.
		
	else:
		shade.visible = true
		menu.visible = true
		menu.position = lerp(menu.position, GlobalParam.center + Vector2(randf_range(-shake, shake), randf_range(-shake, shake)), delta * randi_range(0,2))
		if menu.position - GlobalParam.center >= Vector2(DisplayServer.window_get_size()) or menu.position + GlobalParam.center <= -Vector2(DisplayServer.window_get_size()):
			menu.position = -menu.position
		
		one.global_position = Corner1[0].global_position + Vector2(40,30)
		if GlobalParam.kk == true:
			one.visible = true
		else:
			one.visible = false
		if k == 1:
			t += delta
			if t >= 1.:
				t = 0.
				shake += 1.0
			if Input.is_action_just_pressed("up_mid_mouse"):
				shake += 5.0
			if Input.is_action_just_pressed("down_mid_nouse"):
				shake -= 5.0
		else: 
			shake = 0.
			t = 0.

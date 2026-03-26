extends Node2D

@onready var sig_nc = $bcg/newgame
@onready var sig_sett = $bcg/settings
@onready var settmenu = $sett_submenu
var soundloudnoise
var soundpulse
var loudnoise
var pulse
var sounds := [FileAccess.open("res://core/started/mus/mm_loud_background.mp3", FileAccess.READ), FileAccess.open("res://core/started/mus/mm_dropPulse2.mp3", FileAccess.READ)]

signal now_sett
signal now_new

@onready var hash_data = 	[ ## ПОРЯДОК ОБРАЩЕНИЯ К ЭТОМУ МАССИВУ ИДЁТ СПРАВА НАЛЕВО, ПЕРВЫЙ НОМЕР \/
							sounds[0].get_buffer(sounds[0].get_length()),							#0
							sounds[1].get_buffer(sounds[1].get_length()),							#1
							$bcg.get_modulate(),													#2
							$shad,																	#3
							$bcg/shad_bcg, 															#4 
							[																		#5 \|/
							$bcg/Logo1,														#0 - 	#5  |
							$bcg/Logo2														#1 - 	#5  |
							],																		#5  '
							$bcg/Logo1.get_transform(),												#6
							[				##Цвета для раскраса фона								#7 \||/
							[				##Постоянная - не менять						#0 \|/ 	#7  ||
							Color(1.199, 1.199, 1.199),							#0 - 	#0  | 	#7  ||
							Color(0.671, 0.671, 0.671)							#1 - 	#0  | 	#7  ||
							],																#0  ' 	#7  ||
																									#7  ||
							[				##Текущая										#1 \|/ 	#7  ||
							Color(1.199, 1.199, 1.199),							#0 - 	#1  | 	#7  ||
							Color(0.671, 0.671, 0.671)							#1 - 	#1  | 	#7  ||
							]																#1  ' 	#7  ||
							],																		#7  ''
							[				##Массивы координат										#8 \|/
							null,															#0 - 	#8  |
							null															#1 - 	#8  |
							]																		#8  '
							]

var k := 0

##================================================

var p := [0, false, false]
#Новая игра
#первый - состояние переключения (0 - не выбрано, 1 - переход в новой игры)
#второй - состояние (false - не в меню новой игры, true - в меню новой игры)
#третий - переход в гл.меню (false - бездействие,  true - переход в гл.меню)


var pp := [0, false, false]
#Настройки

var spdBCG := 1.
var ppp = [false, false, false, false]

##=================================================

var l := 0.
var kk = false
@export var L := [70., 70., 170.]

@onready var backs = [$bcg/bcg_back, $bcg/bcg_inmass, $bcg/bcg_middle, $bcg/bcg_front]
@onready var backs_scroll_speed = [backs[0].get_autoscroll(),backs[1].get_autoscroll(),backs[2].get_autoscroll(),backs[3].get_autoscroll()]
@onready var buttoms = [sig_nc, sig_sett]
@onready var peses = [sig_nc.get_position(), sig_sett.get_position()]




func _ready() -> void:
	if get_node("/root/GlobalParam").get("nodes") != null:
		GlobalParam.nodes.append(name)
		GlobalParam.nodes.append(self)
		GlobalParam.nodes.append($bcg/newgame.name)
		GlobalParam.nodes.append($bcg/newgame)
		GlobalParam.nodes.append($bcg/settings.name)
		GlobalParam.nodes.append($bcg/settings)
		GlobalParam.nodes.append("bcg")
		GlobalParam.nodes.append(backs)
	sig_nc.new.connect(new)
	sig_sett.push.connect(sett)
	soundloudnoise = AudioStreamPlayer.new()
	soundpulse = AudioStreamPlayer.new()
	loudnoise = AudioStreamMP3.new()
	pulse = AudioStreamMP3.new()
	pulse.data = hash_data[1]
	loudnoise.data = hash_data[0]
	soundloudnoise.stream = loudnoise
	soundpulse.stream = pulse
	soundpulse.set_max_polyphony(15)
	soundloudnoise.set_max_polyphony(499)
	soundloudnoise.set_autoplay(true)
	add_child(soundloudnoise)
	add_child(soundpulse)
	hash_data[3].set_as_top_level(true)
	hash_data[4].set_as_top_level(true)
	hash_data[4].material.set_shader_parameter("value", 0.3)
	hash_data[5][1].modulate.a = 0.
	hash_data[5][1].transform = hash_data[6]
	
	await get_tree().create_timer(0.5).timeout
	
	var posblyat1 = FileAccess.open("res://core/logic/posblyat1.txt", FileAccess.WRITE)
	posblyat1.store_string(str(sig_sett.pis[0], " ", sig_sett.pis[1], " ", sig_sett.pis[2]))
	posblyat1.close()
	posblyat1 = FileAccess.get_file_as_string("res://core/logic/posblyat1.txt")
	DirAccess.remove_absolute("res://core/logic/posblyat1.txt")
	
	var posblyat2 = FileAccess.open("res://core/logic/posblyat2.txt", FileAccess.WRITE)
	posblyat2.store_string(str(sig_nc.pis[0], " ", sig_nc.pis[1], " ", sig_nc.pis[2]))
	posblyat2.close()
	posblyat2 = FileAccess.get_file_as_string("res://core/logic/posblyat2.txt")
	DirAccess.remove_absolute("res://core/logic/posblyat2.txt")
	
	hash_data[8] = (
	func():
		var one = posblyat1.split(" ")
		var two = posblyat2.split(" ")
		var tree : Array
		var fore : Array
		for i in one:
			tree.append(float(i))
		for i in two:
			fore.append(float(i))
		return [tree, fore]
		).call()
	print(hash_data[8])
	settmenu.modulate.a = 0.
	
func _process(delta: float) -> void:
	hash_data[6] = $bcg/Logo1.get_transform()
	hash_data[3].size = GlobalParam.mainWinSize
	hash_data[3].position = GlobalParam.leftUPcorner
	hash_data[4].size = GlobalParam.mainWinSize
	hash_data[4].global_position = GlobalParam.leftUPcorner
	if p[0] == 1:
		if p[1] == false:
			sig_nc.set_modulate(lerp(sig_nc.get_modulate(), Color(1.0, 1.0, 1.0, 0.0), delta*2))
			sig_sett.set_modulate(lerp(sig_nc.get_modulate(), Color(1.0, 1.0, 1.0, 0.0), delta*2))
			spdBCG = lerpf(spdBCG, -100, delta)
			for i in buttoms.size():
				hash_data[3].material.set_shader_parameter("value", -(buttoms[i].get_modulate().a - 1))
			for i in range(3).size():
				sig_nc.pis[i] = lerp(sig_nc.pis[i], hash_data[8][1][i] * 100, delta * 5)
				sig_sett.pis[i] = lerp(sig_sett.pis[i], hash_data[8][0][i] * 100, delta * 5)
				print(sig_nc.pis[i], " ", sig_sett.pis[i])
				if hash_data[8][1][i] < sig_nc.pis[i] and hash_data[8][0][i] < sig_sett.pis[i]:
					hash_data[7][1][0] = lerp(hash_data[7][1][0], Color(hash_data[7][0][0] / 10, 1.0), delta)
					hash_data[7][1][1] = lerp(hash_data[7][1][1], Color(hash_data[7][0][1] / 10, 1.0), delta)
					if hash_data[8][1][i] * 100 - 0.01 < sig_nc.pis[i] and hash_data[8][0][i] * 100 - 0.01 < sig_sett.pis[i]:
						sig_nc.pis[i] = hash_data[8][1][i] * 100
						sig_sett.pis[i] = hash_data[8][0][i] * 100
						if hash_data[8][1][i] * 100 == sig_nc.pis[i] and hash_data[8][0][i] * 100 == sig_sett.pis[i]:
							sig_nc.set_process_mode(Node.PROCESS_MODE_DISABLED)
							sig_sett.set_process_mode(Node.PROCESS_MODE_DISABLED)
							for iii in buttoms.size():
								buttoms[iii].hide()
							p[1] = true

				pass
		pass
	if pp[0] == 1:
		if pp[1] == false:
			sig_nc.set_process_mode(Node.PROCESS_MODE_DISABLED)
			sig_sett.set_process_mode(Node.PROCESS_MODE_DISABLED)
			sig_nc.set_modulate(lerp(sig_nc.get_modulate(), Color(1.0, 1.0, 1.0, 0.0), delta*2))
			sig_sett.set_modulate(lerp(sig_nc.get_modulate(), Color(1.0, 1.0, 1.0, 0.0), delta*2))
			spdBCG = lerpf(spdBCG, 300, delta)
			for i in buttoms.size():
				hash_data[3].material.set_shader_parameter("value", -(buttoms[i].get_modulate().a - 1))
				buttoms[i].position = clamp(buttoms[i].position, -Vector2(GlobalParam.mainWinSize * 2) + peses[i], Vector2(GlobalParam.mainWinSize * 2) + peses[i])
				buttoms[i].set_position(lerp(buttoms[i].get_position(), Vector2(lerp(backs[3].get_autoscroll(), backs[0].get_autoscroll(), buttoms[i].get_modulate().a)) + peses[i] , delta))
				if buttoms[i].get_modulate().a != 1.0:
					$bcg.move_child(buttoms[i], snappedi(lerp($bcg.get_child_count() - 1, 0, buttoms[i].get_modulate()), 1))
					if buttoms[i].get_modulate().a <= 0.1:
						buttoms[i].hide()
						pp[1] = true

	if p[1] != false or pp[1] != false and not (p[1] != false and pp[1] != false):
		spdBCG = lerpf(spdBCG, 1, delta)
		if spdBCG >= 1.01 or spdBCG <= 0.99:
			if hash_data[5][1].modulate.a <= 0.9:
				hash_data[5][1].modulate.a = lerpf(hash_data[5][1].modulate.a,1,delta)
			else:
				if hash_data[5][1].modulate.a != 1:
					hash_data[5][1].modulate.a = 1
					if p[1] != false:
						now_new.emit()
					if pp[1] != false:
						now_sett.emit()
						
			if hash_data[5][1].modulate.a == 1 and hash_data[5][0].modulate.a >= .001:
				hash_data[5][0].modulate.a = lerpf(hash_data[5][0].modulate.a,0,delta)
				if hash_data[5][0].modulate.a <= 0.01:
					hash_data[5][0].modulate.a = 0 
		pass
	
	for i in backs.size():
		backs[i].set_autoscroll(lerp(backs[i].get_autoscroll(), (backs_scroll_speed[i] * 2) * spdBCG, delta * l * 100))
		if kk == false:
			backs[i].set_modulate(lerp(backs[i].get_modulate(), hash_data[7][1][1], delta * l * 5))
	l += delta
	if kk == false:
		if !soundloudnoise.is_playing():
			soundloudnoise.set_playing(true)
	if l >= 60 / L[0]:
		for i in backs.size():
			backs[i].set_autoscroll(backs_scroll_speed[i] / 2)
			if kk == false:
				backs[i].set_modulate(hash_data[7][1][0])
		soundpulse.play()
		l = 0.
	if k == 1:
		L[0] = lerp(L[0], L[2], delta * 0.2) 
	if k == 0:
		L[0] = lerp(L[0], L[1], delta * 0.1) 
	if L[0] >= 220.0 and kk != true:
		kk = true
		
	if kk == true:
		for i in backs.size():
			backs[i].set_modulate(Color(1.0, 0.004, 0.0, 1.0))
		soundloudnoise.play()
		await get_tree().create_timer(5).timeout
		get_tree().quit()
	pass

func new(argnew):
	print("ОПА ", argnew)
	p[0] = 1

func sett(argsett):
	print("ОПАПА ", argsett)
	pp[0] = 1
	

func _on_newgame_mouse_entered() -> void:
	k = 1 

func _on_newgame_mouse_exited() -> void:
	k = 0 

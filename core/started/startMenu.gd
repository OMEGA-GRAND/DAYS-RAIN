extends Node2D

@onready var sig_nc = $bcg/newgame
@onready var sig_sett = $bcg/settings
var soundloudnoise
var soundpulse
var loudnoise
var pulse
var sounds := [FileAccess.open("res://core/started/mus/mm_loud_background.mp3", FileAccess.READ), FileAccess.open("res://core/started/mus/mm_dropPulse2.mp3", FileAccess.READ)]
signal now

@onready var hash_data = 	[
							sounds[0].get_buffer(sounds[0].get_length()),		#0
							sounds[1].get_buffer(sounds[1].get_length()),		#1
							$bcg.get_modulate(),								#2
							$shad,												#3
							$bcg/shad_bcg, 										#4
							[$bcg/Logo1, $bcg/Logo2],							#5
							$bcg/Logo1.get_transform()							#6
							]

var k := 0

##================================================

var p := 0


var pp = [0, 1.0, false, false, false, false]

var ppp = [false, false, false, false]

##=================================================

var l := 0.
var kk = false
@export var L := [50., 50., 140.]

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

func _process(delta: float) -> void:
	hash_data[6] = $bcg/Logo1.get_transform()
	hash_data[3].size = GlobalParam.mainWinSize
	hash_data[3].position = GlobalParam.leftUPcorner
	hash_data[4].size = GlobalParam.mainWinSize
	hash_data[4].global_position = GlobalParam.leftUPcorner
	if p == 1:
		pass
	if pp[0] == 1:
		if pp[2] == false:
			sig_nc.set_process_mode(Node.PROCESS_MODE_DISABLED)
			sig_sett.set_process_mode(Node.PROCESS_MODE_DISABLED)
			sig_nc.set_modulate(lerp(sig_nc.get_modulate(), Color(1.0, 1.0, 1.0, 0.0), delta*2))
			sig_sett.set_modulate(lerp(sig_nc.get_modulate(), Color(1.0, 1.0, 1.0, 0.0), delta*2))
			pp[1] = lerpf(pp[1], 300, delta)
			for i in buttoms.size():
				hash_data[3].material.set_shader_parameter("value", -(buttoms[i].get_modulate().a - 1))
				buttoms[i].position = clamp(buttoms[i].position, -Vector2(GlobalParam.mainWinSize * 2) + peses[i], Vector2(GlobalParam.mainWinSize * 2) + peses[i])
				buttoms[i].set_position(lerp(buttoms[i].get_position(), Vector2(lerp(backs[3].get_autoscroll(), backs[0].get_autoscroll(), buttoms[i].get_modulate().a)) + peses[i] , delta))
				if buttoms[i].get_modulate().a != 1.0:
					$bcg.move_child(buttoms[i], snappedi(lerp($bcg.get_child_count() - 1, 0, buttoms[i].get_modulate()), 1))
					if buttoms[i].get_modulate().a <= 0.1:
						buttoms[i].hide()
						pp[2] = true
		else:
			pp[1] = lerpf(pp[1], 1, delta)
			if pp[1] >= 1.01 or pp[1] <= 0.99:
				if hash_data[5][1].modulate.a <= 0.9:
					hash_data[5][1].modulate.a = lerpf(hash_data[5][1].modulate.a,1,delta)
				else:
					if hash_data[5][1].modulate.a != 1:
						hash_data[5][1].modulate.a = 1
						now.emit()
				if hash_data[5][1].modulate.a == 1 and hash_data[5][0].modulate.a >= .001:
					hash_data[5][0].modulate.a = lerpf(hash_data[5][0].modulate.a,0,delta)
					if hash_data[5][0].modulate.a <= 0.01:
						hash_data[5][0].modulate.a = 0 
						

			pass

				
		pass
	if p == 0:
		pass
	if pp[0] == 0:
		pass
	
	for i in backs.size():
		backs[i].set_autoscroll(lerp(backs[i].get_autoscroll(), (backs_scroll_speed[i] * 2) * pp[1], delta * l * 100))
		if kk == false:
			backs[i].set_modulate(lerp(backs[i].get_modulate(), Color(0.671, 0.671, 0.671, 1.0), delta * l * 5))
	l += delta
	if kk == false:
		if !soundloudnoise.is_playing():
			soundloudnoise.set_playing(true)
	if l >= 60 / L[0]:
		for i in backs.size():
			backs[i].set_autoscroll(backs_scroll_speed[i] / 2)
			if kk == false:
				backs[i].set_modulate(Color(1.199, 1.199, 1.199, 1.0))
		soundpulse.play()
		l = 0.
	if k == 1:
		L[0] = lerp(L[0], L[2], delta * 0.02) 
	if k == 0:
		L[0] = lerp(L[0], L[1], delta * 0.01) 
	if L[0] >= 220.:
		kk = true
		for i in backs.size():
			backs[i].set_modulate(Color(1.0, 0.004, 0.0, 1.0))
		for i in 500:
			soundloudnoise.play()
		await get_tree().create_timer(5).timeout
		get_tree().quit()
	pass

func new(argnew):
	print("ОПА ", argnew)
	p = 1

func sett(argsett):
	print("ОПАПА ", argsett)
	pp[0] = 1
	

func _on_newgame_mouse_entered() -> void:
	k = 1 

func _on_newgame_mouse_exited() -> void:
	k = 0 

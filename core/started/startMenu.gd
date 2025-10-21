extends Node2D

@onready var signals_new_con = $newgame
@onready var signals_sett = $settings
var soundloudnoise
var soundpulse
var loudnoise
var pulse
var sounds := [FileAccess.open("res://core/started/mus/mm_loud_background.mp3", FileAccess.READ), FileAccess.open("res://core/started/mus/mm_dropPulse.mp3", FileAccess.READ)]


@onready var hash_data = [sounds[0].get_buffer(sounds[0].get_length()), sounds[1].get_buffer(sounds[1].get_length()), $bcg.get_modulate()]

var k := 0
var kk := 0
var l := 0.
var kkk = false
@export var L := [50., 50., 140.]

@onready var backs = [$bcg/back, $bcg/inmass, $bcg/middle, $bcg/front]
@onready var backs_scroll_speed = [backs[0].get_autoscroll(),backs[1].get_autoscroll(),backs[2].get_autoscroll(),backs[3].get_autoscroll()]



func _ready() -> void:
	if get_node("/root/GlobalParam").get("nodes") != null:
		GlobalParam.nodes.append(name)
		GlobalParam.nodes.append(self)
		GlobalParam.nodes.append($newgame.name)
		GlobalParam.nodes.append($newgame)
		GlobalParam.nodes.append($settings.name)
		GlobalParam.nodes.append($settings)
	signals_new_con.new.connect(new)
	signals_sett.push.connect(sett)
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

func _process(delta: float) -> void:
	if kk == 1:
		pass
	for i in backs.size():
		backs[i].set_autoscroll(lerp(backs[i].get_autoscroll(), backs_scroll_speed[i], delta * l * 100))
		if kkk == false:
			backs[i].set_modulate(lerp(backs[i].get_modulate(), Color(1.0, 1.0, 1.0, 1.0), delta * l))
	l += delta
	if kkk == false:
		if !soundloudnoise.is_playing():
			soundloudnoise.set_playing(true)
	if l >= 60 / L[0]:
		for i in backs.size():
			backs[i].set_autoscroll(backs_scroll_speed[i] * -1)
			if kkk == false:
				backs[i].set_modulate(Color(1.0, 0.828, 0.799, 1.0))
		soundpulse.play()
		
		l = 0.
	if k == 1:
		L[0] = lerp(L[0], L[2], delta * 0.2) 
	if k == 0:
		L[0] = lerp(L[0], L[1], delta * 0.1) 
	if L[0] >= 220.:
		kkk = true
		for i in backs.size():
			backs[i].set_modulate(Color(1.0, 0.004, 0.0, 1.0))
		for i in 500:
			soundloudnoise.play()
		await get_tree().create_timer(5).timeout
		get_tree().quit()
	pass
	
func new(arg):
	print("ОПА ", arg)

func sett(arg):
	print("ОПА ", arg)
	kk = 1



func _on_newgame_mouse_entered() -> void:
	k = 1 




func _on_newgame_mouse_exited() -> void:

	k = 0 

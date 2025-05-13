extends CSGBox3D

var target
var ch 
var que
var posi

func _ready():
	que = name.split(", ", true, 3)
	posi = Vector3(int(que[0]), int(que[1]), int(que[2]))
	ch = get_parent().chanks **2

func _process(_delta):
	target = get_parent().find_child("character").position
	position = round(target / 5) * 5 + posi
	print("ОПА")

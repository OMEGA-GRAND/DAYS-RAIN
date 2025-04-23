extends Node3D

@export var chanks = 7
var code 
var cube = []
var map


func _ready():
	map = FastNoiseLite.new()
	map.noise_type = FastNoiseLite.TYPE_CELLULAR
	map.set_cellular_distance_function(FastNoiseLite.DISTANCE_MANHATTAN)
	$spr.set_texture(map.get_image(chanks * 6, chanks * 6))
	#$spr.size = Vector2(DisplayServer.window_get_size())
	var x1 = 0
	var y1 = 0
	var pos = 0
	var steps = 1
	var step_count = 0
	for i in chanks**2:
		cube.append(CSGBox3D.new())
	for i in chanks**2:
		step_count += 1
		cube[i].name = str(x1, ", ", 0, ", ", y1, ", ", i)
		match pos:
			0:
				y1 -= 5
			1:
				x1 += 5
			2:
				y1 += 5
			3:
				x1 -= 5
		
		if step_count == steps:
			step_count = 0
			pos = (pos + 1) % 4
			if pos % 2 == 0:
				steps += 1
	code = GDScript.new()
	
	code.source_code = """
extends CSGBox3D

var target
var ch 
var que
var posi
var zone = CollisionShape3D.new() 
var shap = BoxShape3D.new()
var area = Area3D.new()

func _ready():
	zone.set_shape(shap)
	zone.shape.size = Vector3(5,5,5)
	add_child(area)
	area.add_child(zone)
	que = name.split(", ", true, 3)
	posi = Vector3(int(que[0]), 0, int(que[2]))
	ch = get_parent().chanks **2
func _process(_delta):
	target = get_parent().find_child("character").position
	position = round(target / 5) * 5 + posi
	position.y = 0
	if position.distance_to(get_parent().find_child("character").position) > 20:
		set_visible(false)
	else:
		set_visible(true)"""
	for i in chanks**2:
		code.reload()
		cube[i].set_script(code)
		var a = StandardMaterial3D.new()
		a.albedo_color = Color(0, 0.373, 0.824)
		cube[i].set_material(a)
		add_child(cube[i])
		
	
	pass
func _process(_delta):
	pass

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
	zone.shape.size = Vector3(4.95,4.95,4.95)
	add_child(area)
	area.add_child(zone)
	que = name.split(", ", true, 3)
	posi = Vector3(int(que[0]), 0, int(que[2]))
	ch = get_parent().chanks **2
	set_process(true)
	
func _process(_delta):
	target = get_parent().find_child("character").position
	position = round(target / 5) * 5 + posi
	position.y = 0
	if position.distance_to(get_parent().find_child("character").position) > 20:
		set_visible(false)
	else:
		set_visible(true)

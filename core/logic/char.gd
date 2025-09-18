extends Camera3D

var time = 0
var mouse_pos = Vector2(0,0)
var move_speed: float = 10.0
var kk = false
var shaker
signal on_off

func _ready():
	# Захват мыши
	if !GlobalParam.nodes.has(self):
		GlobalParam.nodes.append(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_parent().find_child("InGameMenu").connect("shshake", signals)

func signals(data):
	if data is Array:
		if data[0] == "shake":
			shaker = data[1]

func _input(event):
	# Управление поворотом камеры с помощью мыши
	if event is InputEventMouseMotion:
		rotation.x = clampf(lerpf(rotation.x, rotation.x - event.relative.y * GlobalParam.mouse_sensitivity[2], lerpf(time, 16 * time, time)), -PI/2, PI/2) 
		if rotation.y >= 360. or rotation.y <= -360.0:
			rotation.y = 0.
		rotation.y = lerpf(rotation.y, rotation.y - event.relative.x * GlobalParam.mouse_sensitivity[2], lerpf(time, 16 * time, time))
	pass

func _process(delta):
	
	time = delta
	if kk == true:
		GlobalParam.mouse_sensitivity[2] = lerp(GlobalParam.mouse_sensitivity[1] ,GlobalParam.mouse_sensitivity[0], shaker / 100 )
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		GlobalParam.mouse_sensitivity[2] = GlobalParam.mouse_sensitivity[0]
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("2nd_side_mouse") or Input.is_action_just_pressed("Э"):
		if kk == false:
			on_off.emit(["OnOff", 1.0])
			kk = true
		else:
			on_off.emit(["OnOff", 0.0])
			kk = false

	
	# Создаём Vector3, где каждая компонента задаётся через get_axis
	var dir = Vector3(
		Input.get_axis("A", "D"), 			 # Ось X: A (влево) и D (вправо)
		Input.get_axis("Ctrl", "Space"),     # Ось Y: Ctrl (вниз) и Space (вверх)
		Input.get_axis("W", "S") 			 # Ось Z: S (назад) и W (вперёд)
		)
	var h_dir = transform.basis * Vector3(dir.x, 0, dir.z)
	var local_dir = h_dir + Vector3(0, dir.y, 0)

	position += local_dir * move_speed * delta
	

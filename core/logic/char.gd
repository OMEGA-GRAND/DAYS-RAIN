extends Camera3D

var time = 0
var mouse_pos = Vector2(0,0)
var move_speed: float = 10.0
var mouse_sensitivity: float = 0.3
var kk = false

func _ready():
	# Захват мыши
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Управление поворотом камеры с помощью мыши
	if event is InputEventMouseMotion:
		rotation.x = clampf(lerpf(rotation.x, rotation.x - event.relative.y * mouse_sensitivity, lerpf(time, 16 * time, time)), -PI/2, PI/2) 
		rotation.y = lerpf(rotation.y, rotation.y - event.relative.x * mouse_sensitivity, lerpf(time, 16 * time, time))
	pass

func _process(delta):
	time = delta
	if kk == true:
		mouse_sensitivity = 0.09
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		mouse_sensitivity = 0.3
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("2nd_side_mouse") or Input.is_action_just_pressed("Э"):
		if kk == false:
			kk = true
		else:
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
	

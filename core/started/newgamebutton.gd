extends Area2D

@export var k := false
var posses := [Vector2(30.,30.)]
var t

signal new 
@warning_ignore("unused_signal")
signal con

func _ready() -> void:

	t = Timer.new()
	t.wait_time = randf_range(0, 1)
	add_child(t)
	t.start()
	for i in get_children(true):
		if i is Sprite2D:
			posses.append([i.position, i, i.position])
			posses.append([i.get_child(0).position, i.get_child(0)])


func _on_mouse_entered() -> void:
	k = true


func _on_mouse_exited() -> void:
	k = false


func _process(delta: float) -> void:
	if k == true:
		if t.get_time_left() <= 0.1:
			t.start(randf_range(0, 0.5))
			for i in posses:
				if i is Array:
					if len(i) > 2:
						i[0] = i[2]
					if len(i) < 3:
						i[0] = Vector2.ZERO
					i[0].x = lerp(i[0].x, i[0].x + (randi_range(10, 70) * randf_range(-1, 1)), delta *50)
					i[0].y = lerp(i[0].y, i[0].y + (randi_range(10, 45) * randf_range(-1, 1)), delta *50)
					i[0].x = clamp(i[0].x, i[0].x - 1, i[0].x + 1)
					i[0].y = clamp(i[0].y, i[0].y - 1, i[0].y + 1)
		for i in posses:
			if i is Array:
				i[1].position.x = lerp(i[1].position.x, i[1].position.x + i[0].x + (posses[0].x * randf_range(-1, 1)), delta *30)
				i[1].position.y = lerp(i[1].position.y, i[1].position.y + i[0].y + (posses[0].y * randf_range(-1, 1)), delta *30)
				i[1].position = lerp(i[1].position, i[0], delta *100) 
		if Input.is_action_just_pressed("L_mouse"):
			emit_signal("new", "newest")


	if k == false:
		if t.get_time_left() <= 0.1:
			t.start(randf_range(0, 2))
			for i in posses:
				if i is Array:
					if len(i) > 2:
						i[0] = i[2]
					if len(i) < 3:
						i[0] = Vector2.ZERO
					i[0].x = lerp(i[0].x, i[0].x + (randi_range(20, 40) * randf_range(-1, 1)), delta *20)
					i[0].y = lerp(i[0].y, i[0].y + (randi_range(20, 35) * randf_range(-1, 1)), delta *20)
					i[0].x = clamp(i[0].x, i[0].x - 1, i[0].x + 1)
					i[0].y = clamp(i[0].y, i[0].y - 1, i[0].y + 1)
		for i in posses:
			if i is Array:
				if i[1].position != i[0] and len(i[1].name) <= 2:
					i[1].position = lerp(i[1].position, i[0], delta)
				if len(i[1].name) > 2:
					i[1].position.x = lerp(i[1].position.x, i[1].position.x + i[0].x + (posses[0].x * randf_range(-1, 1)), delta *60)
					i[1].position.y = lerp(i[1].position.y, i[1].position.y + i[0].y + (posses[0].y * randf_range(-1, 1)), delta *40)
					i[1].position = lerp(i[1].position, i[0], delta *100) 

	

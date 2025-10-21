extends Area2D

@export var k := false
var posses := [Vector2(30.,30.)]
var t

signal push

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
		if Input.is_action_just_pressed("L_mouse"):
			emit_signal("push", "click")

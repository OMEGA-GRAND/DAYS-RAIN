extends Node2D

@onready var nodes = [$SubMenuPart, $SubMenuPart2, $SubMenuPart3, $SubMenuPart4, $SubMenuPart5, $SubMenuPart6]

var deb = [false, 1., NAN, NAN, NAN, NAN, NAN, NAN]
var alpha = [1., 1., 1., 1., 1., 1.]
var color = []
var sizes = []

func _ready() -> void:
	for i in nodes:
		i.set_as_top_level(true)
		i.self_modulate.a = 0
		sizes.append(i.texture.get_size())
		color.append(Color(i.modulate.r, i.modulate.g, i.modulate.b))
	pass

func _process(delta: float) -> void:
	if deb[0] == true:
		var a : Vector2 = GlobalParam.zero_point + (GlobalParam.mainWinSize / 2.)
		var b = (
			func():
				var k : int
				var F = GlobalParam.mainWinSize.x / 5
				var FF = 0.1
				match k:
					1:
						k = F 
					2: 
						k = F * 2
					3:
						k = F * 3
					4: 
						k = F * 4
					5: 
						k = F * 5
				return k
				).call()
		for i in nodes.size():
			nodes[i-1].self_modulate.a = lerpf(nodes[i-1].self_modulate.a, alpha[i-1], delta)
			if nodes[i-1].self_modulate.a >= alpha[i-1] - 0.1:
				nodes[i-1].self_modulate.a = alpha[i-1]
			nodes[0].position = a 
			nodes[0].scale = Vector2i(1, 1)
			nodes[1].position = a
			nodes[1].scale = Vector2i(1, 1)
			nodes[2].position = a
			nodes[2].scale = Vector2i(1, 1)
			nodes[3].position = a
			nodes[3].scale = Vector2i(1,1)
			nodes[4].position = a
			nodes[4].scale = Vector2i(1,1)
			nodes[5].position = a
			nodes[5].scale = Vector2i(1,1)
			if Rect2(nodes[i-1].global_position - (nodes[i-1].scale * nodes[i-1].texture.get_size() / 2), nodes[i-1].scale * nodes[i-1].texture.get_size()).has_point(get_global_mouse_position()):
				alpha[i-1] = lerpf(alpha[i-1], 1.5, delta * 5)
			else:
				alpha[i-1] = lerpf(alpha[i-1], 1., delta * 5)
				
		
func _on_startmenu_now() -> void:
	deb[0] = true

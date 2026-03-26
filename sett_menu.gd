extends Node2D

@onready var nodes = [$SubMenuPart, $SubMenuPart2, $SubMenuPart3, $SubMenuPart4, $SubMenuPart5, $SubMenuPart6]

var deb = [false, 1., NAN, NAN, NAN, NAN, NAN, NAN]
var alpha = [255., 255., 255., 255., 255., 255.]
var RealAlpha = []
var sizes = []
var l = 0.1

func _ready() -> void:
	for i in nodes.size():
		RealAlpha.append(nodes[i - 1].modulate.a)
	for i in nodes:
		i.set_as_top_level(true)
		i.modulate.a = 0.
	pass

func _process(delta: float) -> void:
	if deb[0] == true:
		var a : Vector2 = GlobalParam.zero_point + (GlobalParam.mainWinSize / 2.)
		var b = (
			func():
				var k : int
				var F = (GlobalParam.mainWinSize.x / 5.) 
				var FF = (GlobalParam.mainWinSize.y / 4.)
				var allX = []
				var allY = []
				var allX_ = []
				var allY_ = []
				var allPOS = []
				for i in range(1, 6):
					k = i
					match k:
						1:
							allX.append(F)
						2: 
							allX.append(F * 2)
						3:
							allX.append(F * 3)
						4: 
							allX.append(F * 4)
						5: 
							allX.append(F * 5)
				for i in range(1, 5):
					k = i
					match k:
						1:
							allY.append(FF)
						2: 
							allY.append(FF * 2)
						3:
							allY.append(FF * 3)
						4: 
							allY.append(FF * 4)
				for i in range(1, 6):
					k = i
					match k:
						1:
							allX_.append((F - (F/2)) - (GlobalParam.mainWinSize.x / 2.))
						2: 
							allX_.append((F * 2 - (F/2)) - (GlobalParam.mainWinSize.x / 2.))
						3:
							allX_.append((F * 3  - (F/2)) - (GlobalParam.mainWinSize.x / 2.))
						4: 
							allX_.append((F * 4  - (F/2)) - (GlobalParam.mainWinSize.x / 2.))
						5: 
							allX_.append((F * 5 - (F/2)) - (GlobalParam.mainWinSize.x / 2.))
				for i in range(1, 5):
					k = i
					match k:
						1:
							allY_.append((FF - (FF/2)) - (GlobalParam.mainWinSize.y / 2.))
						2: 
							allY_.append((FF * 2 - (FF/2)) - (GlobalParam.mainWinSize.y / 2.))
						3:
							allY_.append((FF * 3  - (FF/2)) - (GlobalParam.mainWinSize.y / 2.))
						4: 
							allY_.append((FF * 4 - (FF/2)) - (GlobalParam.mainWinSize.y / 2.))
				allPOS.append(allX)
				allPOS.append(allY)
				allPOS.append(allX_)
				allPOS.append(allY_)
				return allPOS
				).call()
		for i in nodes.size():
			if nodes[i-1].modulate.a != alpha[i-1]:
				nodes[i-1].modulate.a = lerpf(nodes[i-1].modulate.a, alpha[i-1], delta)
				if nodes[i-1].modulate.a >= alpha[i-1] - 2:
					nodes[i-1].modulate.a = alpha[i-1]
			
			nodes[0].position = Vector2(b[2][0], GlobalParam.center.y)
			nodes[0].scale = Vector2i(1, 1)
			nodes[1].position = Vector2(b[2][1], GlobalParam.center.y)
			nodes[1].scale = Vector2i(1, 1)
			nodes[2].position = lerp(Vector2(b[2][2], b[3][0]), Vector2(b[2][3] ,b[3][0]), 0.5)
			nodes[2].scale = Vector2i(1, 1)
			nodes[3].position = lerp(Vector2(b[2][2], b[3][3]), Vector2(b[2][3], b[3][1]), 0.5)
			nodes[3].scale = Vector2i(1,1)
			nodes[4].position = lerp(Vector2(b[2][3], b[3][0]), Vector2(b[2][4], b[3][0]), 0.5)
			nodes[4].scale = Vector2i(1,1)
			nodes[5].position = lerp(Vector2(b[2][3], b[3][3]), Vector2(b[2][4], b[3][1]), 0.5)
			nodes[5].scale = Vector2i(1,1)
			
				
		


func _on_startmenu_now_sett() -> void:
	deb[0] = true

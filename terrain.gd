extends Node

func _ready() -> void:
	$"../IGM".connect("imge_comple", terr)

func terr(noise) -> void:
	
	pass
	

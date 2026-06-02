extends Node

# Базовые параметры состояния персонажа
var base = get_parent()
var hunger: float = 100.
var thirst: float = 100.
var healfactor: float = 100.
var stamina: float = 100.
var adrenaline: float = 0.
var all = [str(hunger),str(thirst),str(healfactor),str(stamina)]

func _ready() -> void:
	
	pass

func _process(delta: float) -> void:
	if GlobalParam.stage == "InGame":
		for i in all:
			if base.get(i) < self.get(i) or self.get(i) < 0.:
				GlobalParam.ABORT((func(): if get_path() == get_path_to($none):  return str(name) else: return get_path()).call(), "ОШИБА ДАННЫХ!!!")
		metabolism(delta)

func metabolism(delta: float) -> void:
	
	pass

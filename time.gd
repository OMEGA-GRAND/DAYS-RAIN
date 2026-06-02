extends Node

var Day_Night_TimeHours : int = 8
var current_time : Array[int]
var current_date : Array[int]


func _ready() -> void:
	if get_node("/root/GlobalParam").get("nodes") != null:
		GlobalParam.nodes.append(name)
		GlobalParam.nodes.append(self)

func _process(delta: float) -> void:
	match current_time:
		[8,0,0]:
			current_time = [0,0,0]
			
		

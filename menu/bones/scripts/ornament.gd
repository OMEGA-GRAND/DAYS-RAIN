extends Marker2D

@export var pos = position
@export var Gpos = global_position

func _process(_delta: float) -> void:
	pos = position
	Gpos = global_position

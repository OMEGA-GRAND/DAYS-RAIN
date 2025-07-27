extends Sprite2D

@export var pos = position
@export var Gpos = global_position
@export var anchors = []

func _process(_delta: float) -> void:
	pos = position
	Gpos = global_position
	anchors = [
	(
		(func():
			var one = $anchor
			var two = $anchor2
			if one != null and two != null:
				return [{"1LG" : [one.position, one.global_position]}, {"2LG" : [two.position, two.global_position]}]
).call())]

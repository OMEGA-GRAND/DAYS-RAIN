extends Sprite2D


@onready var one = $anchor
@onready var two = $anchor2
@export var pos : Vector2
@export var Gpos  : Vector2
@export var anchors = []

func _ready() -> void:
	pos = position
	Gpos = global_position
	anchors = [[one.position, one.global_position],[two.position, two.global_position]]

func _process(_delta: float) -> void:
	pos = position
	Gpos = global_position
	anchors = [[one.position, one.global_position],[two.position, two.global_position]]
	

extends ColorRect

var shaker
var openClose


@onready var root = $"../.."
@onready var OpenClose = %CircleShadow

func _ready() -> void:
	root.connect("shshake", signals)
	OpenClose.connect("on_off", signals)


func signals(data):
	if data is Array:
		if data[0] == "shake":
			shaker = data[1]
		if data[0] == "OnOff":
			openClose = data[1]



func _process(_delta):
	material.set_shader_parameter("u_active", openClose)
	

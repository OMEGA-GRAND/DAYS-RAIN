extends ColorRect
var k = 1.0
var key
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self is ColorRect:
		k = lerp(k, 0.0, delta)
		material.set_shader_parameter("value", k)
		if material.get_shader_parameter("value") <= 0.01:
			print("опа")
			free()
		if is_instance_valid(self):
			if material.get_shader_parameter("value") >= 0.011:
				size = DisplayServer.window_get_size()
				position = GlobalParam.window_size

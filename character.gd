extends CharacterBody2D

var SPEED : float
var SPPEDD : float


@onready var dot1 = $"../dot1_body"
@onready var dot2 = $"../dot2_body"
@onready var col1 = $"../dot1_body/dot1_coll"
@onready var col2 = $"../dot2_body/dot2_coll"



func _physics_process(delta):
	#var vector_iner = (position - dot1.position).normalized()
	var direction = Vector2(Input.get_axis("A", "D"), Input.get_axis("W", "S")).normalized()
	var distance = dot1.position.distance_to(dot2.position)
	var dis1_self = snapped(dot1.position.distance_to(position), .01)
	$"../Camera".position = position
	$ProgressBar.global_position = global_position + Vector2(40,-80)
	
	move_and_slide()
	dot1.move_and_slide()
	dot2.move_and_slide()
	
	if direction:
		if dis1_self > 60:
			$ProgressBar.value -= dis1_self * 0.007
		elif dis1_self < 60 and dis1_self > 30:
			$ProgressBar.value += dis1_self * 0.001
		elif dis1_self < 30:
			$ProgressBar.value += dis1_self * 0.003
	else:
		$ProgressBar.value += 45 * 0.004
	
	
	if distance > SPPEDD:
		var vector = (dot2.position - dot1.position).normalized()
		dot2.position = clamp(dot2.position, dot1.position,  dot1.position + vector * SPPEDD) 
	
		
	if direction:
		dot2.velocity.x = direction.x * SPEED 
		dot2.velocity.y = direction.y * SPEED
	else:
		dot2.velocity = velocity
		dot2.position = lerp(dot2.position, position, delta * (SPEED / 100))
		
	if direction:
		dot1.position = lerp(dot1.position, dot2.position, delta * (SPEED / 100))
	else:
		dot1.velocity = direction
		dot1.position = lerp(dot1.position, position, delta * (SPEED / 100))
		
	#while not direction:
		#pass
		
	if direction:
		if Input.is_action_pressed("Shift"):
			col1.scale = lerp(col1.scale, Vector2(.7,.7), delta * 3)
			col2.scale = lerp(col2.scale, Vector2(.6,.6), delta * 3)
			SPPEDD = lerp(SPPEDD, 100.0, delta * 3)
			SPEED = lerp(SPEED, 270.0, delta * 3)
		else:
			col1.scale = lerp(col1.scale, Vector2(1,1), delta * 3)
			col2.scale = lerp(col2.scale, Vector2(1,1), delta * 3)
			SPPEDD = lerp(SPPEDD, 100.0, delta * 3)
			SPEED = lerp(SPEED, 150.0, delta * 3)
		position = lerp(position, dot1.position, delta * ((SPEED / 100) + 1))
	else:
		col1.scale = lerp(col1.scale, Vector2(1,1), delta * 3)
		col2.scale = lerp(col2.scale, Vector2(1,1), delta * 3)
		SPPEDD = lerp(SPPEDD, 100.0, delta * 3)
		SPEED = lerp(SPEED, 150.0, delta * 3)
		position = lerp(position, dot1.position, delta * ((SPEED / 100) + 2))
	
	$Label.global_position = global_position + Vector2(20,-20)
	#$Label.text = str("Скорость: ", snapped(SPEED, 0.01), ". Уст.отступ: ", snapped(SPPEDD, .01), ". Направление движения: ", vector_iner)
	$"../dot1_body/Label".global_position = dot1.global_position + Vector2(20,-20)
	$"../dot1_body/Label".text = str("К персонажу: ", snapped(dot1.position.distance_to(position), .01), ".")
	$"../dot2_body/Label".global_position = dot2.global_position + Vector2(20,-20)
	$"../dot2_body/Label".text = str("К первой точке: ", snapped(dot2.position.distance_to(dot1.position), .01), ".")

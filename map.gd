extends Node

# Глобальные переменные
var sizi = Vector2i(2000, 2000)			# Размер изображения
var square_size = Vector2i(100, 100)	# Размер одного квадрата
var a = FastNoiseLite.new()				# Объект FastNoiseLite
var threads = []						# Список потоков
var squares = {}						# Словарь для хранения квадратов
var mutex = Mutex.new()					# Мьютекс для защиты общих данных
var completed_threads = 0				# Счётчик завершённых потоков
var window_size
var node
var q : float
var i = false
var nod = CSGSphere3D.new()
var progress = (((float(sizi.x) / float(square_size.x) * (float(sizi.y) / float(square_size.y))) * 7) + 8) / 100000
@onready var efw : Array = [{"name" : ""}, {"name_property" : ""}, {"typed_value" : null}, {"type_of_math_operatin" : ""}]:
	set = set_get
@onready var deb = $progress/debug

func set_get(val : Array):
	if val.size() == 2:
		print_rich("Получение значения свойства....")
		if val[0] is String:
			node = get_parent().find_child(val[0])
			if node == null:
				printerr("Целевая нода не найдена!")
		else:
			printerr("Не верный тип названия ноды.")
		if val[1] is String and node != null:
			var memb = node.get_property_list()
			for k in memb.size():
				if val[1] in memb[k]["name"]:
					break
				else:
					if node == null:
						pass
					else:
						if k == memb.size() - 1:
							printerr("Передано несуществующее свойство в ноде: ", node)
		else:
				if node == null:
					pass
				else:
						printerr("Не верный тип названия свойства ноды.")
	if val.size() == 3 or val.size() == 4:
		print_rich("Установка значения свойства....")
		if val[0] is String:
			node = get_parent().find_child(val[0])
			if node == null:
				printerr("Целевая нода не найдена!")
		else:
			printerr("Не верный тип названия ноды.")
		if val[1] is String and node != null:
			var memb = node.get_property_list()
			for k in memb.size():
				if val[1] in memb[k]["name"]:
					break
				else:
					if node == null:
						pass
					else:
						if k == memb.size() - 1:
							printerr("Передано несуществующее свойство в ноде: ", node)
		else:
				if node == null:
					pass
				else:
						printerr("Не верный тип названия свойства ноды.")
		if (val[2] is String or val[2] is int or val[2] is float or val[2] is bool) and node != null:
			if typeof(node.get(val[1])) == typeof(val[2]):
				if val[2] is int or val[2] is float:
					if val.size() == 4 and val[3] is String:
						if val[3] == "+": 
							node.set(val[1], node.get(val[1]) + val[2])
						if val[3] == "-": 
							node.set(val[1], node.get(val[1]) - val[2])
						if val[3] == "*": 
							node.set(val[1], node.get(val[1]) * val[2])
						if val[3] == "/":
							node.set(val[1], node.get(val[1]) / val[2])
					elif val.size() == 3: 
						node.set(val[1], val[2])
				else:
					node.set(val[1], val[2])
		else:
				if node == null:
					pass
				else:
					printerr("Не верный тип передаваемого значения свойства.")
		pass

func _ready():
	efw = ["progress", "visible", false]
	pass
	
	

func _process(_delta):
	q = clamp(q, 0.0, 100.0)
	$progress.value = q
	$progress.position = GlobalParam.debug_control.position + Vector2(0,30)
	$InGameMenu/spr.position += Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up") * 3
	if Input.is_action_just_pressed("Ctrl"):
		efw = ["progress", "visible", true]
		if i == false:
			i = true
			if sizi.x >= 6000 or sizi.y >= 6000:
				sizi = Vector2i(3000, 3000)
				print_rich("Попытка установить разрешение сверх опасного. Теперь оно равно: ", sizi)
				
			print_rich("Начало выполнения программы.")
			deb.append_text(str("Начало... [p]"))
			# Настройка FastNoiseLite
			a.noise_type					= FastNoiseLite.TYPE_VALUE_CUBIC
			a.seed							= randi()
			a.domain_warp_frequency			= randf_range(0.7, 0.1)
			a.domain_warp_amplitude			= randi_range(100, 70)
			a.cellular_jitter				= randf_range(0.7, 0.2)
			a.cellular_distance_function	= FastNoiseLite.DISTANCE_HYBRID
			a.domain_warp_fractal_gain		= randf_range(0.5, 0.4)
			print_rich("FastNoiseLite настроен: тип шума=", a.noise_type, ", seed=", a.seed)
			q += progress
			# Запуск потоков для генерации квадратов
			for x in range(sizi.x / square_size.x):
				for y in range(sizi.y / square_size.y):
					print_rich("[color=green]x=", x, ", y=", y, "[/color]  Запуск потока... ")
					deb.append_text(str("[color=green]x=", x, ", y=", y, "[/color]  Запуск потока... [p]"))
					q += progress
					var thread = Thread.new()
					threads.append(thread)
					await get_tree().create_timer(0.001).timeout
					thread.start(Callable(self, "_generate_square").bind(x, y, thread), Thread.PRIORITY_NORMAL)
		else:
			printerr("				ГЕНЕРАЦИЯ УЖЕ ЗАПУЩЕНА!				")
			deb.append_text(str("				[color=red][bgcolor=black]ГЕНЕРАЦИЯ УЖЕ ЗАПУЩЕНА![/bgcolor][/color]				[p]"))

func _generate_square(x, y, id):
	
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  1. Начата работа.")
	deb.append_text(str("[color=green]x=", x, ", y=", y, "[/color] [color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color] Начата работа."))
	q += progress
	# Создание локальной копии FastNoiseLite
	var local_noise							= FastNoiseLite.new()
	local_noise.noise_type					= a.noise_type
	local_noise.seed						= a.seed
	local_noise.domain_warp_frequency		= a.domain_warp_frequency
	local_noise.domain_warp_amplitude		= a.domain_warp_amplitude
	local_noise.cellular_jitter				= a.cellular_jitter
	local_noise.cellular_distance_function	= a.cellular_distance_function
	local_noise.domain_warp_fractal_gain	= a.domain_warp_fractal_gain
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  2. Создана копия FastNoiseLite.")
	q += progress
	# Установка offset для текущего квадрата
	local_noise.offset = Vector3(x * square_size.x, 0.0, y * square_size.y) / square_size.x
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  3. Установлен offset = ", local_noise.offset)
	q += progress
	# Создание изображения для квадрата
	var square_image = Image.create(square_size.x, square_size.y, false, Image.FORMAT_RGB8)
	
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  4. Создано пустое изображение, размер = ", square_image.get_size())
	q += progress
	for px in range(square_size.x):
		for py in range(square_size.y):
			var noise_value = local_noise.get_noise_2d(px + x * square_size.x, py + y * square_size.y)
			var red		= snapped(clampf(randf_range(noise_value, noise_value + 0.1), 0.0, 1.0), 0.005)
			var green	= snapped(clampf(randf_range(noise_value, noise_value + 0.1), 0.0, 1.0), 0.005)
			var blue	= snapped(clampf(randf_range(noise_value, noise_value + 0.1), 0.0, 1.0), 0.005)
			var color	= Color(red, green, blue, 1.0)
			square_image.set_pixel(px, py, color)
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  5. Заполнен.")
	q += progress
	# Сохранение квадрата в словарь
	mutex.lock()
	squares[Vector2i(x, y)] = square_image
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  6. Сохранён, размер = ", square_image.get_size())
	mutex.unlock()
	q += progress
	
	# Увеличиваем счётчик завершённых потоков
	completed_threads += 1
	print_rich("[color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color]  [color=green]x=", x, ", y=", y, "[/color]  7. Завершён, всего завершено = ", completed_threads)
	deb.append_text(str("[color=green]x=", x, ", y=", y, "[/color] [color=red][bgcolor=black]№", id.get_id(), "[/bgcolor][/color] Завершён, всего завершено = ", completed_threads, "[p]"))
	q += progress
	
	if completed_threads == (sizi.x / square_size.x) * (sizi.y / square_size.y):
		completed_threads = 0
		deb.clear()
		print_rich("Потоки завершены. Вызов _assemble_image()...")
		print_rich("Просмотр потоков, запуск _check_threads()...")
		call_deferred("_check_threads")
		call_deferred("_assemble_image")
		q += progress

func _check_threads():
	
	var check = []
	for x in threads:
		check.append(str("Поток: №", x.get_id(), " Активен? : ", x.is_alive()))
		if x.is_alive() == false:
			x.wait_to_finish()
			threads[threads.find(x)] = "Удалён"
		else:
			printerr("ОШИБКА! КАКОЙ-ТО ИЗ ПОТОКОВ НЕ БЫЛ ЗАВЕРШЁН!", " Работающий поток: №", x.get_id())
			get_tree().quit()
	await get_tree().create_timer(0.5).timeout
	print_rich(threads.size())
	threads.clear()
	print_rich(threads)
	q += progress

func _assemble_image():
	print_rich("Начало сборки изображения.")
	q += progress
	# Создаём новое изображение для сборки
	var final_image = Image.create(sizi.x, sizi.y, false, Image.FORMAT_RGB8)
	print_rich("Создано целевое изображение размером: ", sizi)
	q += progress
	# Собираем квадраты в одно изображение
	for x in range(sizi.x / square_size.x):
		for y in range(sizi.y / square_size.y):
			var key = Vector2i(x, y)
			
			if not squares.has(key):
				printerr("Ошибка: Квадрат с координатами [color=green]x=", x, ", y=", y, "[/color]", " отсутствует в словаре!")
				continue
			
			var square = squares[key]
			print_rich("Чтение:			[color=green]x=", x, ", y=", y, "[/color]", ", размер=", square.get_size())
			q += progress
			if square.get_size() == Vector2i.ZERO:
				printerr("Ошибка: Квадрат с координатами [color=green]x=", x, ", y=", y, "[/color]", " имеет нулевой размер!")
				continue
			
			var dst = Vector2i(x * square_size.x, y * square_size.y)
			print_rich("Копирование:	[color=green]x=", x, ", y=", y, "[/color]", ", координаты назначения=", dst)
			final_image.blit_rect(square, Rect2i(Vector2i.ZERO, square_size), dst)
			q += progress
	print_rich("Сборка изображения завершена. Преобразование в текстуру.")
	
	# Преобразуем изображение в текстуру
	var texture = ImageTexture.create_from_image(final_image)
	$InGameMenu/spr.texture = texture
	final_image.save_png("res://menu/noise.png")
	print_rich("Текстура успешно применена к TextureRect.")
	i = false
	squares.clear()
	q += progress
	efw = ["progress", "visible", false]
	q = 0

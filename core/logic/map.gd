extends Node

# Глобальные переменные
var sizi = Vector2i(1000, 1000)			# Размер изображения
var square_size = Vector2i(100, 100)	# Размер одного квадрата
var a = FastNoiseLite.new()				# Объект FastNoiseLite
var threads = []						# Список потоков
var squares = {}						# Словарь для хранения квадратов
var mutex = Mutex.new()					# Мьютекс для защиты общих данных
var completed_threads = 0				# Счётчик завершённых потоков
var center
var node
var q : float
var i = false
var file_log_gen
var nod = CSGSphere3D.new()
var progress = 100. / (2 + ((sizi.x * sizi.y) / (square_size.x * square_size.y)) + 6 + (((sizi.x * sizi.y) / (square_size.x * square_size.y)) * 7))
var flow_deb_text : String
var FILEflow_deb_text : String
var texture

@onready var cam = $Cam
@onready var deb = $progress/debug

signal imge_comple

func _ready():
	print(progress)
	$progress.step = progress
	$progress.visible = false
	pass

func _process(_delta):
	cam.position = GlobalParam.zero_point
	
	mutex.lock()
	if flow_deb_text.split("[p]").size() >= 7:
		deb.set_text(
			flow_deb_text.right(
				(
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 1].length() + 3 
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 2].length() + 3 
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 3].length() + 3 
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 4].length() + 3 
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 5].length() + 3 
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 6].length() + 3 
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 7].length() + 3
				+
				flow_deb_text.split("[p]")[flow_deb_text.split("[p]").size() - 8].length() + 3 
				)
			)
		)
	else:
		deb.set_text(
			flow_deb_text.left(170)
			)
	mutex.unlock()
	
	q = clamp(q, 0.0, 100.0)
	$progress.value = q
	
	$progress.position = GlobalParam.leftUPcorner
	if Input.is_action_just_pressed("Ctrl"):
		if texture is ImageTexture:
			texture = null
		$progress.visible = true
		if i == false:
			i = true
			if sizi.x >= 6001 or sizi.y >= 6001:
				sizi = Vector2i(3000, 3000)
			mutex.lock()
			flow_deb_text += str("[p]Начало... ")
			FILEflow_deb_text += str("""Начало..|
""")
			mutex.unlock()
			# Настройка шума
			a.noise_type					= FastNoiseLite.TYPE_VALUE_CUBIC
			a.seed							= randi()
			a.domain_warp_frequency			= randf_range(0.7, 0.1)
			a.domain_warp_amplitude			= randi_range(100, 70)
			a.cellular_jitter				= randf_range(0.7, 0.2)
			a.cellular_distance_function	= FastNoiseLite.DISTANCE_HYBRID
			a.domain_warp_fractal_gain		= randf_range(0.5, 0.4)
			q += progress
			FILEflow_deb_text += str("""Шум настроен... |
""")
			# Запуск потоков для генерации квадратов
			for x in range(sizi.x / square_size.x):
				for y in range(sizi.y / square_size.y):
					mutex.lock()
					flow_deb_text += str("[p][color=green]x=", x, ", y=", y, "[/color]  Запуск потока... ")
					mutex.unlock()
					q += progress
					var thread = Thread.new()
					threads.append(thread)
					await get_tree().create_timer(0.001).timeout
					thread.start(Callable(self, "_generate_square").bind(x, y, thread), Thread.PRIORITY_NORMAL)
		else:
			printerr("				ГЕНЕРАЦИЯ УЖЕ ЗАПУЩЕНА!				")
			mutex.lock()
			flow_deb_text += str("[p]				[color=red][bgcolor=black]ГЕНЕРАЦИЯ УЖЕ ЗАПУЩЕНА![/bgcolor][/color]				")
			mutex.unlock()


func _generate_square(x, y, id):
	@warning_ignore("integer_division")
	mutex.lock()
	@warning_ignore("integer_division")
	flow_deb_text += str("[p][color=green]x=", x, ", y=", y, "[/color] [color=red][bgcolor=black]№", str((int(id.get_id()) / 2) - 20), "[/bgcolor][/color] Начата работа.")
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), """ 1. Начата работа..|
""")
	mutex.unlock()
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
	@warning_ignore("integer_division")
	mutex.lock()
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), """ 2. Взята копия шума..|
""")
	mutex.unlock()
	q += progress
	# Установка offset для текущего квадрата
	local_noise.offset = Vector3(x * square_size.x, 0.0, y * square_size.y) / square_size.x
	@warning_ignore("integer_division")
	mutex.lock()
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), " 3. Установлен offset: ", local_noise.offset,  """|
""")
	mutex.unlock()
	q += progress
	# Создание изображения для квадрата
	var square_image = Image.create(square_size.x, square_size.y, false, Image.FORMAT_RGB8)
	
	@warning_ignore("integer_division")
	mutex.lock()
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), " 4. Создано пустое изображение с размером: ", square_image.get_size(),  """|
""")
	mutex.unlock()
	q += progress
	for px in range(square_size.x):
		for py in range(square_size.y):
			var noise_value = local_noise.get_noise_2d(px + x * square_size.x, py + y * square_size.y)
			var rgb		= snapped(clampf(randf_range(noise_value, noise_value + 0.1), 0.0, 1.0), 0.05)
			var color	= Color(rgb, rgb, rgb, 1.0)
			square_image.set_pixel(px, py, color)
	@warning_ignore("integer_division")
	mutex.lock()
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), """ 5. Квадрат заполнен.|
""")
	mutex.unlock()
	q += progress
	# Сохранение квадрата в словарь
	mutex.lock()
	squares[Vector2i(x, y)] = square_image
	@warning_ignore("integer_division")
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), " 6. Квадрат сохранён с размером: ", square_image.get_size(),  """|
""")
	mutex.unlock()
	q += progress
	
	# Увеличиваем счётчик завершённых потоков
	completed_threads += 1
	@warning_ignore("integer_division")
	mutex.lock()
	@warning_ignore("integer_division")
	flow_deb_text += str("[color=green]x=", x, ", y=", y, "[/color] [color=red][bgcolor=black]№", str((int(id.get_id()) / 2) - 20), "[/bgcolor][/color] Завершён, всего завершено = ", completed_threads)
	@warning_ignore("integer_division")
	FILEflow_deb_text += str("x=", x, ", y=", y, " №", str((int(id.get_id()) / 2) - 20), " 7. Поток завершил свою работу, всего завершено: ", completed_threads,  """|
""")
	mutex.unlock()
	q += progress
	
	if completed_threads == (sizi.x / square_size.x) * (sizi.y / square_size.y):
		completed_threads = 0
		call_deferred("_check_threads")
		call_deferred("_assemble_image")
		mutex.lock()
		FILEflow_deb_text += str("""Потоки завершены, завершение генерации, подготовка изображения, очистка потоков.. |
""")
		mutex.unlock()
		q += progress

func _check_threads():
	deb.clear()
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
	threads.clear()
	FILEflow_deb_text += str("""Потоки очищены. |
""")
	q += progress

func _assemble_image():
	FILEflow_deb_text += str("""Собираю изображение.. |
""")
	q += progress
	# Создаём новое изображение для сборки
	var final_image = Image.create(sizi.x, sizi.y, false, Image.FORMAT_RGB8)
	FILEflow_deb_text += str("Создано пустое финальное изображение с размером: ", sizi, """ |
""")
	q += progress
	# Собираем квадраты в одно изображение
	for x in range(sizi.x / square_size.x):
		for y in range(sizi.y / square_size.y):
			var key = Vector2i(x, y)
			
			if not squares.has(key):
				printerr("Ошибка: Квадрат с координатами [color=green]x=", x, ", y=", y, "[/color]", " отсутствует в словаре!")
				continue
			
			var square = squares[key]
			FILEflow_deb_text += str("Чтение:			[color=green]x=", x, ", y=", y, "[/color]", ", размер=", square.get_size(), """ |
""")
			q += progress
			if square.get_size() == Vector2i.ZERO:
				printerr("Ошибка: Квадрат с координатами [color=green]x=", x, ", y=", y, "[/color]", " имеет нулевой размер!")
				continue
			
			var dst = Vector2i(x * square_size.x, y * square_size.y)
			FILEflow_deb_text += str("Копирование:	[color=green]x=", x, ", y=", y, "[/color]", ", координаты назначения=", dst, """ |
""")
			final_image.blit_rect(square, Rect2i(Vector2i.ZERO, square_size), dst)
			q += progress
	FILEflow_deb_text += str("""Изображение собрано, пребразование в текстуру.. |
""")
	# Преобразуем изображение в текстуру
	texture = ImageTexture.create_from_image(final_image)
	final_image.save_png("res://menu/noise.png")
	print_rich("Текстура успешно создана.")
	FILEflow_deb_text += str("""Ггенерация завершена. |
""")
	i = false
	squares.clear()
	q += progress
	$progress.visible = false
	q = 0
	FILEflow_deb_text += str("""Код генерации отработал без ошибок. Образование дебаг-лога... |
""")
	var ii = FILEflow_deb_text.split("|")
	if FileAccess.file_exists("res://core/gen_log.txt"):
		file_log_gen = FileAccess.open("res://core/gen_log.txt", FileAccess.WRITE)
		for K in ii.size():
			file_log_gen.store_string(ii[K - 1])
		file_log_gen.close()
		pass
	else:
		printerr("Файл-лога не существует, он будет создан...")
		file_log_gen = FileAccess.open("res://core/gen_log.txt", FileAccess.WRITE)
		for K in ii.size():
			file_log_gen.store_string(ii[K - 1])
		file_log_gen.close()
	flow_deb_text = ""
	emit_signal("imge_comple", texture)

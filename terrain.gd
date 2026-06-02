extends Node

signal chunks_ready

var Global_MAP
var copy_gen
var real

var chunks_library : Dictionary = {}
const CHUNK_SIZE = 50
const CHUNKS_SIZE = 50
const SAVE_DIR = "user://terrain_chunks/"
const LOG_FILE = "user://gen_log.txt"

func _ready() -> void:
	$"../IGM".connect("imge_comple", terr)
	$"../IGM".connect("imge_state", st)

func terr(noise) -> void:
	if noise.has_meta("realOrNot") and noise.get_meta("realOrNot") == real:
		copy_gen = noise
		_start_generation_process()
	else:
		GlobalParam.ABORT( (func(): if get_path() == get_path_to($none):  return str(name) else: return get_path()).call(), "НЕ ДЕЙСТВИТЕЛЬНЫЙ ПАТТЕРН ВЫСОТ!")
		pass
	
func st(id) -> void:
	real = id

func _start_generation_process() -> void:
	chunks_library.clear() #чистим мусор
	DirAccess.make_dir_absolute(SAVE_DIR) #сохраняем

	var width = copy_gen.get_width()
	var height = copy_gen.get_height()
	var cols = width / CHUNK_SIZE
	var rows = height / CHUNK_SIZE
  
	var offset_x = cols / 2
	var offset_y = rows / 2
  
	var iterations = 0
  
	for y in range(rows):
		for x in range(cols):
			var rect = Rect2i(x * CHUNKS_SIZE, y * CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE)
			var chunk: Image = copy_gen.get_region(rect)
	  
			var coord_x = offset_x - x#ключ координата
			var coord_y = offset_y - y
			var key = str(coord_x) + "." + str(coord_y)
			chunks_library[key] = chunk
			chunk.save_png(SAVE_DIR + "chunk_" + key + ".png")
	  	
			iterations += 1 #от зависаний
			if iterations >= 100:
				iterations = 0 
				await get_tree().process_frame 
				_update_log_file()
				chunks_ready.emit()

#снос старых файлов
func _update_log_file() -> void:
	var file = FileAccess.open(LOG_FILE, FileAccess.WRITE)
	if file:
		file.store_string("=== GENERATION LOG ===\n")
		for key in chunks_library.keys():
			file.store_string("Generation chunk: " + key + "\n")
			file.close()


extends Node
# Этот узел управляет общими характеристиками персонажа, координируя модули.

# Назначьте узлы модулей в инспекторе Godot
@export var health_module_path : NodePath
@export var mental_module_path : NodePath
@export var physical_module_path : NodePath
@export var needs_module_path : NodePath

@onready var health = get_node_or_null(health_module_path)
@onready var mental = get_node_or_null(mental_module_path)
@onready var physical = get_node_or_null(physical_module_path)
@onready var needs = get_node_or_null(needs_module_path)

func _ready():
	# Подключаем сигналы для межмодульного
	# Убеждаемся, что модули существуют перед подключением
	if health and physical:
		# Здоровье влияет на Выносливость
		health.physical.connect("health_changed_percent", "_on_Health_changed_percent")
		# Кровотечение влияет на Здоровье
		physical.health.connect("bleeding_updated", "_on_Bleeding_updated")
		# Боль влияет на физическую производительность
		health.physical.connect("pain_changed", "_on_Pain_changed")
	if health and mental:
		# Боль влияет на Стресс/Рассудок
		health.mental.connect("pain_changed", "_on_Pain_changed")
		# Низкое здоровье влияет на Рассудок
		health.mental.connect("health_critical", "_on_Health_critical")
	if mental and health:
		# Стресс влияет на Сердечный ритм
		mental.health.connect("stress_changed", "_on_Stress_changed")
		# Рассудок влияет на восприятие (обрабатывается в другом месте, но сигнал полезен)
		# mental.connect("sanity_changed", self, "_on_Sanity_changed") # Пример
	if physical and health:
		#Нагрузка влияет на Дыхание/Сердечный ритм (возможно, косвенно через события)
		pass # Физические действия будут вызывать функции модуля здоровья напрямую
	if needs and health:
		needs.health.connect("needs_status_changed", "_on_Needs_status_changed")
	if needs and mental:
		needs.mental.connect("needs_status_changed", "_on_Needs_status_changed")
	if needs and physical:
		needs.physical.connect("needs_status_changed", "_on_Needs_status_changed")
		# Первоначальное обновление на основе значений по умолчанию
		
	#if health and mental and physical:
		#health.update_dependencies(mental.stress_level, physical.get_activity_level(), health.pain_level)
	#if physical and health and needs:
		#physical.update_modifiers(health.pain_level, needs.fatigue, health.get_health_percentage())
		# Пример того, как другие системы могут взаимодействовать с этими характеристиками
		## НЕ РАБОЧЕЕ
		
func apply_damage(amount: float, damage_type: String = "blunt"):
	if health:
		health.take_damage(amount)
		# Потенциально добавляем специфические эффекты в зависимости от типа урона
	if physical and damage_type == "sharp":
		physical.add_bleeding(amount * 0.1) # Пример: Режущий урон вызывает кровотечение
	if physical and damage_type == "blunt" and randf() < 0.1: # 10% шанс перелома от тупого удара
		physical.add_fracture("limb", amount * 0.2) # Пример логики перелома

func apply_stressor(amount: float):
	if mental:
		mental.add_stress(amount)
func perform_heavy_activity(duration: float):
	if physical:
		physical.exert(duration * 5.0) # Пример затрат выносливости
	if health:
		health.increase_activity_level(2.0) # Увеличиваем физиологическую нагрузку
		# Потребности могут расти быстрее во время активности - возможно, обрабатывается в NeedsModule
func rest(duration: float, quality: float = 1.0):
	if needs:
		needs.recover_fatigue(duration * 10.0 * quality)
	if mental:
		mental.recover_stress(duration * 5.0 * quality)
		mental.recover_sanity(duration * 1.0 * quality) # Рассудок восстанавливается медленно
	if health:
		health.heal(duration * 0.5 * quality) # Медленное пассивное лечение во время отдыха
		health.reduce_pain(duration * 2.0 * quality)
		health.increase_activity_level(-1.0) # Снижаем физиологическую нагрузку
		
# --- Обработчики сигналов от модулей (Опциональная централизованная обработка) ---
# Пример: Реагируем на изменения рассудка глобально, если нужно
#func _on_Sanity_changed(new_sanity):
#    print("Рассудок персонажа теперь: ", new_sanity)
#    if new_sanity < 30:
#        print("ВНИМАНИЕ: Персонаж видит то, чего нет!")
		# Запускаем логику появления фантомов здесь

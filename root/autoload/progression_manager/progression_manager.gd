extends Node

@export var progression_data: ProgressionData

func _ready() -> void:
	# Дублируем ресурс при старте, чтобы изменения в памяти
	# не влияли на исходный файл .tres на диске.
	if progression_data:
		progression_data = progression_data.duplicate()

func set_flag(flag: String, value: bool) -> void:
	if not progression_data:
		push_error("ProgressionData not properly assigned!")
		return

	progression_data.state_table[flag] = value

	# Оповещаем редактор об изменении, чтобы оно отобразилось в Remote Inspector
	progression_data.flag_changed.emit(flag, value)
	progression_data.emit_changed()
	print("Flag set: %s = %s" % [flag, value])

func get_flag(flag: String) -> bool:
	if not progression_data:
		push_error("ProgressionData not properly assigned!")
		return false

	return progression_data.state_table.get(flag, false)

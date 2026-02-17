extends Node


@export var progression_data: Resource # ProgressionData


func set_flag(flag: String, value: bool) -> void:
	if not progression_data or not "state_table" in progression_data:
		push_error("ProgressionData not properly assigned!")
		return
	progression_data.state_table[flag] = value


func get_flag(flag: String) -> bool:
	if not progression_data or not "state_table" in progression_data:
		push_error("ProgressionData not properly assigned!")
		return false

	if not flag in progression_data.state_table:
		print("No such progression flag " + flag)
		return false
	return progression_data.state_table[flag]

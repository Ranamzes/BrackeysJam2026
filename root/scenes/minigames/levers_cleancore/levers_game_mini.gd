extends Node2D

@export var levers_check_state : Dictionary[String, bool]
@export var solved_flag_name : String = "levers_solved"

func _ready() -> void:
	ProgressionManager.flag_changed.connect(_on_changed)
	

func _on_changed(flag_name : String, flag_value : bool) -> void:
	print(flag_name)
	print(levers_check_state)
	if levers_check_state.has(flag_name) :
		print(flag_name)
		if check_solved() and !ProgressionManager.get_flag(solved_flag_name):
			ProgressionManager.set_flag(solved_flag_name, true)


func check_solved() -> bool:
	print("debug")
	for key in levers_check_state :
		print(levers_check_state[key])
		if levers_check_state[key] != ProgressionManager.get_flag(key) :
			return false
	return true

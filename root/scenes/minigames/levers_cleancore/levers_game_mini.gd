extends Node2D

@export var levers_check_state : Dictionary[String, bool]
@export var solved_flag_name : String = "levers_solved"

func _ready() -> void:
	ProgressionManager.progression_data.changed.connect(_on_changed)
	
func _on_changed(flag_name : String, flag_value : bool) -> void:
	if levers_check_state.has(flag_name) :
		print(flag_name)
		if check_solved() :
			ProgressionManager.set_flag(solved_flag_name, true)


func check_solved() -> bool:
	for key in levers_check_state :
		if levers_check_state[key] != ProgressionManager.get_flag(key) :
			return false
	return true

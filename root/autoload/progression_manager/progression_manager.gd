extends Node


@export var state_table: Dictionary[String, bool]


func set_flag(flag:String,value:bool)->void:
	state_table[flag]=value;
	
func get_flag(flag:String) ->bool:
	if not flag in state_table:
		print("No such progression flag " + flag)
		return false
	return state_table[flag];
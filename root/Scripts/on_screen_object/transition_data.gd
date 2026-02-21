class_name TransitionData
extends Node

var old_state_name : String
var new_state_name : String
var transition_name : String

func _to_string() -> String:
	return old_state_name + " -> " + new_state_name + "  :  " + transition_name

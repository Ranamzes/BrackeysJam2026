class_name ObjectStateTransition
extends Node2D

@export var new_state : OnScreenObjectState
@export var old_state : OnScreenObjectState
@export var flags_true : Array[String]
@export var flags_false : Array[String]
@export var item_id : String

func  go_to_new_state() -> OnScreenObjectState:
	var slot = GlobalData.selected_slot
	if item_id && (!slot || slot.inventory_slot.item.id != item_id):
		return null
	for flag_true in flags_true:
		if !ProgressionManager.get_flag(flag_true):
			return null
	for flag_false in flags_false:
		if ProgressionManager.get_flag(flag_false):
			return null
	old_state.go_to(new_state)
	return new_state

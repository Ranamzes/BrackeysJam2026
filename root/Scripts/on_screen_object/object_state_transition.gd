class_name ObjectStateTransition
extends Node2D

@export var new_state : OnScreenObjectState
var old_state : OnScreenObjectState
@export var flags_true : Array[String]
@export var flags_false : Array[String]
@export var item_id : String
## Эти переходы будут обрабатываться совместно, для них могу быть проигнорированы условия перехода, с помощью флага force_connected_transitions
@export var connected_transitions : Array[ObjectStateTransition]
@export var force_connected_transitions : bool = false

func _ready() -> void:
	old_state = get_parent()

func  go_to_new_state(force : bool = false) -> OnScreenObjectState:
	if new_state.visible :
		return null
	if !force :
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
	for transition in connected_transitions :
		transition.go_to_new_state(force_connected_transitions)
	return new_state

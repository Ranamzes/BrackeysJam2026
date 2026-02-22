extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ProgressionManager.set_flag("level_1_visited", true)

func flags_changed(flag_name : String, flag_value : bool) -> void:	
	match flag_name:
		"soap_full_picked_up":
			GlobalData.player_inventory.remove_item(preload("res://root/assets/items/soap_empty.tres"))
			GlobalData.player_inventory.add_item(preload("res://root/assets/items/soap_full.tres"))

extends Area2D

class_name InteractableArea
@export var required_item: ItemData
##After interaction will change flag to true
@export var flag_name: String
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if (required_item != null):
				if GlobalData.selected_slot && GlobalData.selected_slot.inventory_slot.item.id == required_item.id:
					GlobalData.player_inventory.remove_item(GlobalData.selected_slot.inventory_slot.item)
					ProgressionManager.set_flag(flag_name, true)
			else:
				ProgressionManager.set_flag(flag_name, true)

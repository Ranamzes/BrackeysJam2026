class_name DialogueVariant
extends Resource

## The title of the dialogue node to start if conditions are met.
@export var start_title: String = "start"

## Dictionary of flag names to their required boolean values.
## Example: { "has_key": true, "enemy_alive": false }
@export var conditions: Dictionary[String, bool] = {}

## Optional item required to trigger this variant.
@export var required_item: ItemData
## If true, the required item will be removed from inventory when dialogue starts.
@export var consume_item: bool = false

## Checks if all conditions are met based on the global ProgressionManager.
func are_conditions_met() -> bool:
	# 1. Check flags
	for flag in conditions:
		var required_value = conditions[flag]
		if ProgressionManager.get_flag(flag) != required_value:
			return false

	# 2. Check item requirement
	if required_item:
		if not GlobalData.selected_slot or not GlobalData.selected_slot.inventory_slot or not GlobalData.selected_slot.inventory_slot.item:
			return false
		if GlobalData.selected_slot.inventory_slot.item.id != required_item.id:
			return false

	return true

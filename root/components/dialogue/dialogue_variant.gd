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
		var current_value = ProgressionManager.get_flag(flag)
		if current_value != required_value:
			# If the flag requires false but doesn't exist yet, register it as false and allow
			if required_value == false and not ProgressionManager.progression_data.state_table.has(flag):
				print("DialogueVariant: Flag '%s' not found, registering as false and activating dialogue." % flag)
				ProgressionManager.set_flag(flag, false)
			else:
				return false

	# 2. Check item requirement
	if required_item:
		if not GlobalData.selected_slot or not GlobalData.selected_slot.inventory_slot or not GlobalData.selected_slot.inventory_slot.item:
			return false
		if GlobalData.selected_slot.inventory_slot.item.id != required_item.id:
			return false

	return true

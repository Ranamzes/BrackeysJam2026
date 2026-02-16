class_name DialogueVariant
extends Resource

## The title of the dialogue node to start if conditions are met.
@export var start_title: String = "start"

## Dictionary of flag names to their required boolean values.
## Example: { "has_key": true, "enemy_alive": false }
@export var conditions: Dictionary[String, bool] = {}

## Checks if all conditions are met based on the global ProgressionManager.
func are_conditions_met() -> bool:
	for flag in conditions:
		var required_value = conditions[flag]
		if ProgressionManager.get_flag(flag) != required_value:
			return false

	return true

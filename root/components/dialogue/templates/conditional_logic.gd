@tool
extends DialogueTrigger

# Override this function to define custom conditional logic.
# Use 'has_flag(name)' to check global state easily.
func _get_active_dialogue_head() -> String:
	# Pattern: Check most specific/advanced conditions first
	# if has_flag("quest_completed"):
	# 	return "thanks_for_help"
	# if has_flag("met_player_once"):
	# 	return "second_greeting"
	# Fallback to the default head set in the Inspector
	return super._get_active_dialogue_head()

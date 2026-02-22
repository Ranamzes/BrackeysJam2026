extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide HUD if quest not started yet
	if not ProgressionManager.get_flag("quest_bottles_started"):
		$Hud.hide()

	# Check if level was already visited
	if not ProgressionManager.get_flag("level_1_visited"):
		# Wait one second then trigger dialogue
		get_tree().create_timer(1.0).timeout.connect(_on_entry_timeout)

	ProgressionManager.progression_data.flag_changed.connect(flags_changed)

func _on_entry_timeout() -> void:
	var lady_tv_trigger = $CharacterTv/DialogueClickable
	if lady_tv_trigger:
		lady_tv_trigger.start_dialogue()

func flags_changed(flag_name: String, _flag_value: bool) -> void:
	match flag_name:
		"quest_bottles_started":
			if _flag_value:
				$Hud.show()
				$Hud.update_navigation()
				var tween = create_tween()
				$Hud.modulate.a = 0
				tween.tween_property($Hud, "modulate:a", 1.0, 1.0)
		"soap_full_picked_up":
			GlobalData.player_inventory.remove_item(preload("res://root/assets/items/soap_empty.tres"))
			GlobalData.player_inventory.add_item(preload("res://root/assets/items/soap_full.tres"))

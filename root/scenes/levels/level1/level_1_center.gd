extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Navigation is now handled by flags in the HUD component
	# Check if level was already visited
	if not ProgressionManager.get_flag("level_1_visited"):
		# Wait one second then trigger dialogue
		get_tree().create_timer(1.0).timeout.connect(_on_entry_timeout)

	# Animate Pena layer appearance if pipes are solved but duck not yet picked up
	if ProgressionManager.get_flag("pipes_solved") and not ProgressionManager.get_flag("duck_picker"):
		var pena = $pena
		pena.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(pena, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	ProgressionManager.progression_data.flag_changed.connect(flags_changed)

func _on_entry_timeout() -> void:
	var lady_tv_trigger = $CharacterTv/DialogueClickable
	if lady_tv_trigger:
		lady_tv_trigger.start_dialogue()

func flags_changed(flag_name: String, _flag_value: bool) -> void:
	match flag_name:
		"quest_bottles_started":
			if _flag_value:
				$Hud.update_navigation()
		"soap_full_picked_up":
			GlobalData.player_inventory.remove_item(preload("res://root/assets/items/soap_empty.tres"))
			GlobalData.player_inventory.add_item(preload("res://root/assets/items/soap_full.tres"))

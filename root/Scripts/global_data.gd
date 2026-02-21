class_name GlobalData
extends Node

static var player_inventory: Inventory
static var selected_slot: ItemSlotUI
static var jars : Array[String] = ["jar_3", "jar_1", "jar_5", "jar_2", "jar_4"]


func _ready() -> void:
	player_inventory = Inventory.new()
	_load_audio_settings()

func _load_audio_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err == OK:
		_apply_audio_bus("Master", config.get_value("Audio", "Master", 1.0))
		_apply_audio_bus("music", config.get_value("Audio", "music", 1.0))
		_apply_audio_bus("sfx", config.get_value("Audio", "sfx", 1.0))
	else:
		_apply_audio_bus("Master", 1.0)
		_apply_audio_bus("music", 1.0)
		_apply_audio_bus("sfx", 1.0)

func _apply_audio_bus(bus_name: String, percent: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1: return

	if percent <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(percent))

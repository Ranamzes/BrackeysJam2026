class_name ProgressionData
extends Resource

@warning_ignore("unused_signal")
signal flag_changed(flag_name: String, flag_value: bool)

@export var state_table: Dictionary[String, bool] = {}

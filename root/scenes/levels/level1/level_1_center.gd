extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ProgressionManager.set_flag("level_1_visited", true)

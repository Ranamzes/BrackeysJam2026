extends Node2D

@onready var test_rect: ColorRect = %TestRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ProgressionManager.get_flag("button_on_right_screen_clicked"):
		test_rect.color = Color.RED

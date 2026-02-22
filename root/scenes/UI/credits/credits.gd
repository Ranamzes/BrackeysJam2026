extends Control

func _ready() -> void:
	# Hide the HUD if it's visible
	# We might want to just transition to this scene and have it be clean.
	pass

func _on_back_button_pressed() -> void:
	ScreenTransition.transition_to_scene("res://root/scenes/UI/main_menu/MainMenu.tscn")

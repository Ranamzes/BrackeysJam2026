extends Control

@export var small_copy : bool = false
@export var shampoo_scale : Vector2 = Vector2(0.15, 0.15);

func _ready() -> void:
	if small_copy :
		%ShampooGame.scale = shampoo_scale
		for child in  %ShampooGame.get_children() :
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

extends Control

@onready var shampoo_game : ShampooGame = %ShampooGame

func _drop_data(at_position: Vector2, data: Variant) -> void:
	shampoo_game.dragging_shampoo.shampoo_texture.modulate = Color.WHITE

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	

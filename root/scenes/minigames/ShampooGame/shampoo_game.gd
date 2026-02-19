class_name ShampooGame
extends HBoxContainer

var dragging_shampoo : DraggableObject
var dragging_offset : Vector2

func check_solved() -> void:
	var shampoos = get_children()
	for i in range(shampoos.size() - 1):
		if shampoos[i].is_empty || shampoos[i].id > shampoos[i+1].id :
			print("not solved!")
			return
	print("solved!")

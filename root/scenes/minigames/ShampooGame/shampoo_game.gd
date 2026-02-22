class_name ShampooGame
extends HBoxContainer

var dragging_shampoo: DraggableObject
var dragging_offset: Vector2
@export var item_data: ItemData
@onready var stream_player: StreamPlayerComponent = %StreamPlayerComponent

func _ready() -> void:
	for idx in range(GlobalData.jars.size()):
		move_child(get_shampoo_by_id(GlobalData.jars[idx]), idx)
	if ProgressionManager.get_flag("bottles_solved"):
		get_shampoo_by_id("jar_3").is_empty = true
		get_shampoo_by_id("jar_3")._ready()

func check_solved() -> void:
	write_jars()
	var shampoos = get_children()
	for i in range(shampoos.size() - 1):
		if not shampoos[i] is DraggableObject:
			continue
		if shampoos[i].is_empty || shampoos[i].id > shampoos[i + 1].id:
			print("not solved!")
			return
	stream_player.play_random()
	if (item_data != null):
		GlobalData.player_inventory.add_item(item_data)
	ProgressionManager.set_flag("bottles_solved", true)
	call_deferred("clear_shampoo")

func clear_shampoo():
	var shampoo = get_tree().get_first_node_in_group("quest_solution")
	if (shampoo != null):
		shampoo.is_empty = true
		shampoo.remove_shampoo()

func write_jars() -> void:
	for i in range(get_children().size()):
		GlobalData.jars[i] = get_child(i).id

func get_shampoo_by_id(id: String) -> DraggableObject:
	for child in get_children():
		if child.id == id:
			return child
	return null

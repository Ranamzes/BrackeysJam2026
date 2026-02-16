class_name GlobalData
extends Node

static var player_inventory : Inventory
static var selected_slot : ItemSlotUI


func _ready() -> void:
	player_inventory = Inventory.new()
	var item_data_1 = preload("res://root/assets/items/test_item_1.tres")
	var item_data_2 = preload("res://root/assets/items/test_item_2.tres")
	var item_data_3 = preload("res://root/assets/items/test_item_3.tres")
	player_inventory.add_item(item_data_1)
	player_inventory.add_item(item_data_2)
	player_inventory.add_item(item_data_3)

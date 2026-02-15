class_name Inventory
extends Node

class ItemSlot:
	var item : ItemData

signal InventoryUpdated

var item_slots : Array[ItemSlot]

func _ready() -> void:
	pass
	
func add_item(new_item : ItemData):
	var slot : ItemSlot = ItemSlot.new()
	slot.item = new_item
	item_slots.append(slot)
	InventoryUpdated.emit()
	
func remove_item(item_to_remove : ItemData):
	var slot = get_item_slot(item_to_remove)
	if slot :
		slot.item = null
		InventoryUpdated.emit();

func get_item_slot(item : ItemData) -> ItemSlot:
	for slot in item_slots :
		if slot.item == item :
			return slot
	return null

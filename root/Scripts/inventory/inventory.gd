class_name Inventory
extends Node

signal InventoryUpdated

var item_slots : Array[ItemSlot]
	
func add_item(new_item : ItemData):
	var slot : ItemSlot = ItemSlot.new()
	slot.item = new_item
	item_slots.append(slot)
	print("adding item")
	print(item_slots)
	ProgressionManager.set_flag(new_item.id + "_picked_up", true)
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

func get_slots() -> Array[ItemSlot]:
	return item_slots

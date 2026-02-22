class_name Inventory
extends Node

signal InventoryUpdated

var item_slots: Array[ItemSlot]

func add_item(new_item: ItemData):
	var slot: ItemSlot = ItemSlot.new()
	slot.item = new_item
	item_slots.append(slot)
	print("adding item")
	print(item_slots)
	ProgressionManager.set_flag(new_item.id + "_picked_up", true)
	InventoryUpdated.emit()

func remove_item(item_to_remove: ItemData):
	var slot = get_item_slot(item_to_remove)
	if slot:
		# Check if this item is currently selected in GlobalData
		if is_instance_valid(GlobalData.selected_slot) and GlobalData.selected_slot.inventory_slot == slot:
			GlobalData.selected_slot.change_selected_state()

		slot.item = null
		InventoryUpdated.emit();

func get_item_slot(item: ItemData) -> ItemSlot:
	for slot in item_slots:
		if slot.item == item:
			return slot
	return null

func get_slots() -> Array[ItemSlot]:
	return item_slots

func add_item_by_path(path: String) -> void:
	var item = load(path)
	if item is ItemData:
		add_item(item)

func remove_item_by_path(path: String) -> void:
	var item = load(path)
	if item is ItemData:
		remove_item(item)

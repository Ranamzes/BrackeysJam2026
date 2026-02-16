extends Container

@onready var player_inventory : Inventory = GlobalData.player_inventory
@onready var vbox_container = %VBoxContainer
@onready var item_slot_packed_scene: PackedScene = preload("res://root/scenes/UI/inventory/ItemSlotUI.tscn")

@export var item_slot_background : Texture2D

func _ready() -> void:
	print("inventory UI ready")
	player_inventory.InventoryUpdated.connect(_on_inventory_updated)
	draw_inventory()
	
func draw_inventory():
	#clear_screen()
	for slot in player_inventory.get_slots():
		add_item_on_screen(slot)
		

func clear_screen():
	print("clearing screen")
	while vbox_container.get_child_count() > 0 :
		var child : Node = vbox_container.get_child(0)
		vbox_container.remove_child(child)
		child.queue_free()
		
func add_item_on_screen(item_slot : ItemSlot):
	print("add item on screen")
	var slot_scene = item_slot_packed_scene.instantiate()
	vbox_container.add_child(slot_scene)
	slot_scene.update_slot(item_slot_background, item_slot.item.icon)
	
func _on_inventory_updated():
	draw_inventory()
	

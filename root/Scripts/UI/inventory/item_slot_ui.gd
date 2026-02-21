class_name ItemSlotUI
extends MarginContainer

@onready var background_texture: TextureRect = %BackgroundTexture
@onready var item_texture: TextureRect = %ItemTexture

@export var background_selected_modulate_color: Color

var inventory_slot: ItemSlot

var is_selected: bool = false

func update_slot(bg_texture: Texture2D, item_slot: ItemSlot):
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	background_texture.texture = bg_texture
	item_texture.texture = item_slot.item.icon
	inventory_slot = item_slot


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if GlobalData.selected_slot && GlobalData.selected_slot != self:
				GlobalData.selected_slot.change_selected_state()
			change_selected_state()

func change_selected_state() -> void:
	if is_selected:
		is_selected = false
		GlobalData.selected_slot = null
		background_texture.modulate = Color.WHITE
	else:
		is_selected = true
		GlobalData.selected_slot = self
		background_texture.modulate = background_selected_modulate_color

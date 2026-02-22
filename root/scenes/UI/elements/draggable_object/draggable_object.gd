class_name DraggableObject
extends PanelContainer

@export var shampoo_texture: TextureRect
@export var id: String
@export var is_empty: bool = false
var shampoo_game: ShampooGame
var def_position: Vector2
var clicks_disabled: bool = false

func _ready() -> void:
	self.gui_input.connect(_on_gui_input)
	shampoo_game = get_parent()
	self_modulate = Color.TRANSPARENT
	if !shampoo_texture:
		shampoo_texture = get_child(0)
		shampoo_texture.mouse_filter = Control.MOUSE_FILTER_PASS
		def_position = shampoo_texture.position
	id = shampoo_texture.texture.resource_path.get_basename().get_file()
	if is_empty:
		shampoo_texture.modulate = Color.TRANSPARENT

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if is_empty && GlobalData.selected_slot && GlobalData.selected_slot.inventory_slot.item.id == id:
				is_empty = false
				shampoo_texture.modulate = Color.WHITE
				GlobalData.player_inventory.remove_item(GlobalData.selected_slot.inventory_slot.item)
				shampoo_game.check_solved()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if is_empty || clicks_disabled:
		return null
	var preview = Control.new()
	var preview_rect = TextureRect.new()
	preview_rect.texture = shampoo_texture.texture
	preview_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview.add_child(preview_rect)
	preview_rect.position = shampoo_texture.global_position - get_global_mouse_position()
	print(preview_rect.position)
	preview_rect.tree_exited.connect(reset_shampoo)
	set_drag_preview(preview)
	shampoo_texture.modulate = Color.TRANSPARENT
	shampoo_game.dragging_shampoo = self
	return self

func reset_shampoo():
	shampoo_game.dragging_shampoo.shampoo_texture.modulate = Color.WHITE
	shampoo_game.dragging_shampoo = null

func remove_shampoo():
	shampoo_texture.modulate = Color.TRANSPARENT

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	print("drop")
	if data != self:
		var drag_idx = data.get_index()
		var self_idx = self.get_index()
		shampoo_game.move_child(self, drag_idx)
		shampoo_game.move_child(data, self_idx)
		shampoo_game.dragging_shampoo.shampoo_texture.modulate = Color.WHITE
	else:
		shampoo_texture.modulate = Color.WHITE
	shampoo_game.check_solved()

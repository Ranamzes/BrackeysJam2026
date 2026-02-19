class_name DraggableObject
extends PanelContainer

@export var shampoo_texture : TextureRect
var shampoo_game : ShampooGame 
var def_position : Vector2

func _ready() -> void:
	self.gui_input.connect(_on_gui_input)
	shampoo_game = get_parent()
	if !shampoo_texture:
		shampoo_texture = get_child(0)
		shampoo_texture.mouse_filter = Control.MOUSE_FILTER_PASS
		def_position = shampoo_texture.position

func _on_gui_input(event: InputEvent) -> void:
	if  event is InputEventMouseButton :
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed() :
				shampoo_game.dragging_offset = get_global_mouse_position()
				shampoo_game.dragging_shampoo = self
			if event.is_released() :
				if shampoo_game.dragging_shampoo == self :
					shampoo_texture.position = def_position
					shampoo_game.dragging_shampoo = null

	

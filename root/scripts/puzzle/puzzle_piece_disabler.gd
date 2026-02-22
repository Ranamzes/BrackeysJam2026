class_name PuzzlePieceDisabler
extends Area2D

var puzzle_piece : PuzzlePiece 
@export var required_item : ItemData
@export var required_item_id : String
@export var required_flags : Array[String]
@export var state_flag_name : String

func _ready() -> void:
	puzzle_piece = get_parent()
	if !ProgressionManager.get_flag(state_flag_name) :
		puzzle_piece.disable()
	self.input_event.connect(_on_input_event)
	
func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	if !puzzle_piece.is_enabled && event is InputEventMouseButton :
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() :
			if !required_item_id || (GlobalData.selected_slot && GlobalData.selected_slot.inventory_slot.item.id == required_item_id) :
				if ProgressionManager.check_flags(required_flags) :
					puzzle_piece.enable()
					GlobalData.player_inventory.remove_item(required_item)
					ProgressionManager.set_flag(state_flag_name, true)

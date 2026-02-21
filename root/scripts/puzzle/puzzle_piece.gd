class_name PuzzlePiece
extends Area2D

@export var puzzle_id : int
@export

var occupied_slot : PuzzlePieceSlot
var puzzle_manager : PuzzleManager
var snap_point : SnapPoint
var is_dragging : bool = false
var dragging_offset : Vector2


func _ready() -> void :
	self.input_event.connect(_on_input_event)
	var parent = get_parent()
	if parent is PuzzleManager : 
		puzzle_manager = parent
	else : 
		printerr("Родительский узел не является PuzzleManager!!! Пазл не будет работать корректно")
	for child in get_children() :
		if child is SnapPoint :
			snap_point = child

func is_correctly_placed() -> bool :
	return occupied_slot && occupied_slot.slot_id == puzzle_id

func try_occupy() -> bool :
	var slot = snap_point.try_snap()
	if slot != null :
		slot.holding_piece = self
		occupied_slot = slot
		return true
	return false

func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int) -> void :
	if puzzle_manager.puzzle_solved :
		return
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() :
			is_dragging = true
			z_index = 100
			unoccupy()
			dragging_offset = global_position - get_global_mouse_position()
		else :
			is_dragging = false
			z_index = 0
			try_occupy()
	elif event is InputEventMouseMotion && is_dragging :
		position = get_global_mouse_position() + dragging_offset
		
func unoccupy() -> void :
	if occupied_slot :
		occupied_slot.holding_piece = null
		occupied_slot = null

	

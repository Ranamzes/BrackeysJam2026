class_name PuzzlePiece
extends Area2D

@export var puzzle_id : int
@export var is_enabled : bool = true
@export var colors : Array[Color] = [Color.WHITE, Color.CYAN, Color.MAGENTA, Color.YELLOW]
@export var required_color_idx : int
var current_color : Color = Color.WHITE
var current_color_idx : int = 0

var occupied_slot : PuzzlePieceSlot
var puzzle_manager : PuzzleManager
var snap_point : SnapPoint
var sprite : Sprite2D 
var is_dragging : bool = false
var dragging_offset : Vector2


func _ready() -> void :
	self.input_event.connect(_on_input_event)
	self.mouse_entered.connect(drop)
	self.mouse_exited.connect(drop)
	var parent = get_parent()
	if parent is PuzzleManager : 
		puzzle_manager = parent
	else : 
		printerr("Родительский узел не является PuzzleManager!!! Пазл не будет работать корректно")
	for child in get_children() :
		if child is SnapPoint :
			snap_point = child
		if child is Sprite2D :
			sprite = child
	if ! is_enabled :
		sprite.visible = false

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
	if ! is_enabled :
		return
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() :
			if puzzle_manager.puzzle_solved :
				change_color()
				return
			is_dragging = true
			z_index = 100
			unoccupy()
			dragging_offset = global_position - get_global_mouse_position()
		else :
			drop()
	elif event is InputEventMouseMotion && is_dragging :
		position = get_global_mouse_position() + dragging_offset

func drop() -> void :
	is_dragging = false
	z_index = 0
	if try_occupy() :
		puzzle_manager.check_solved()

func unoccupy() -> void :
	if occupied_slot :
		occupied_slot.holding_piece = null
		occupied_slot = null

func change_color() -> void :
	var new_idx = (colors.find(current_color) + 1) % colors.size()
	current_color = colors[new_idx]
	current_color_idx = new_idx
	modulate = current_color
	puzzle_manager.check_colors()

func is_color_right() -> bool :
	return current_color_idx == required_color_idx

func solve_color() -> void :
	current_color = colors[required_color_idx]
	current_color_idx = required_color_idx
	modulate = current_color

func disable() -> void:
	is_enabled =  false;
	if sprite :
		sprite.visible = false

func enable() -> void :
	is_enabled = true
	if sprite :
		sprite.visible = true
	

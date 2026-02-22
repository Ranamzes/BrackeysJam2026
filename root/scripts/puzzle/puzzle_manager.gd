class_name PuzzleManager
extends Node2D

@export var pieces_anchors : Array[Node2D]
@export var pieces_solved_flag_name : String = "puzzle_pieces_solved"
@export var colors_solved_flag_name : String = "puzzle_colors_solved"

var puzzle_pieces : Array[PuzzlePiece]
var puzzle_slots : Array[PuzzlePieceSlot]
var puzzle_solved : bool = false
var colors_solved : bool = false

func _ready() -> void:
	for child in get_children() :
		if child is PuzzlePiece :
			puzzle_pieces.append(child)
		if child is PuzzlePieceSlot :
			puzzle_slots.append(child)
	if ProgressionManager.get_flag(pieces_solved_flag_name) :
		solve_puzzle()
	if ProgressionManager.get_flag(colors_solved_flag_name) :
		solve_colors()
		return
	if pieces_anchors.size() > 0 :
		if puzzle_pieces.size() != pieces_anchors.size() :
			printerr("Количество якорей не соответствует количеству пазлов! Пазлов: " + str(puzzle_pieces.size()) + "    Якорей: " + str(pieces_anchors.size()))
		for i in range(min(puzzle_pieces.size(), pieces_anchors.size())) :
			puzzle_pieces[i].position = pieces_anchors[i].position

func check_solved() -> bool :
	for piece in puzzle_pieces :
		if ! piece.is_correctly_placed() :
			return false
	puzzle_solved = true
	ProgressionManager.set_flag(pieces_solved_flag_name)
	return true 
	
func check_colors() -> bool :
	for piece in puzzle_pieces :
		if ! piece.is_color_right() :
			return false
	colors_solved = true
	ProgressionManager.set_flag(colors_solved_flag_name)
	return true
	
func solve_puzzle() -> void:
	for i in range(puzzle_pieces.size()) :
		puzzle_slots[i].install_puzzle(puzzle_pieces[i])

func solve_colors() -> void :
	for puzzle_piece in puzzle_pieces :
		puzzle_piece.solve_color()

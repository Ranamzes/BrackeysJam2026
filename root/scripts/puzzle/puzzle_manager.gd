class_name PuzzleManager
extends Node2D

@export var pieces_anchors : Array[Node2D]

var puzzle_pieces : Array[PuzzlePiece]
var puzzle_solved : bool = false


func _ready() -> void:
	for child in get_children() :
		if child is PuzzlePiece :
			puzzle_pieces.append(child)
	if pieces_anchors.size() > 0 :
		if puzzle_pieces.size() != pieces_anchors.size() :
			printerr("Количество якорей не соответствует количеству пазлов! Пазлов: " + str(puzzle_pieces.size()) + "    Якорей: " + str(pieces_anchors.size()))
		for i in range(min(puzzle_pieces.size(), pieces_anchors.size())) :
			puzzle_pieces[i].position = pieces_anchors[i].position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

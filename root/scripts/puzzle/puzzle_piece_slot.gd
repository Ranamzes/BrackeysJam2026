class_name PuzzlePieceSlot
extends Area2D

static var slots_group_name : String = "puzzle_slots"
@onready var shape = $CollisionShape2D.shape

@export var slot_id : int

var holding_piece : PuzzlePiece

func _ready() -> void:
	self.add_to_group(slots_group_name, true)

func install_puzzle(puzzle : PuzzlePiece) -> void :
	puzzle.global_position = self.global_position

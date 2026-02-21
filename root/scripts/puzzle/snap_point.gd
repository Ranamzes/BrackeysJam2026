class_name SnapPoint
extends Area2D

@onready var parent : PuzzlePiece = get_parent()

func try_snap() -> PuzzlePieceSlot:
	for area in get_overlapping_areas() :
		if area.is_in_group(PuzzlePieceSlot.slots_group_name) :
			area = area as PuzzlePieceSlot
			if area.holding_piece == null :
				parent.global_position = area.global_position
				return area
	return null

extends BoxContainer
@export var disable_clicks : bool = false

func _ready() -> void :
	if disable_clicks :
		for child in %ShampooGame.get_children() :
			child = child as DraggableObject
			child.clicks_disabled = true

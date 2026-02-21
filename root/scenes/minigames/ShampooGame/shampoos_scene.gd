extends BoxContainer
@export var disable_clicks : bool = false
@export var disable_mouse_intercept:bool = false

func _ready() -> void :
	if disable_clicks :
		for child in %ShampooGame.get_children() :
			child = child as DraggableObject
			child.clicks_disabled = true
	if disable_clicks :
		for child in %ShampooGame.get_children() :
			child = child as DraggableObject
			child.mouse_filter = MOUSE_FILTER_IGNORE

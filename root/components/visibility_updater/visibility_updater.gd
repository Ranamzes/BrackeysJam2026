extends Node

class_name VisibilityUpdater
@export var flags : Array[String]

@export var should_be_visible_if_flags_true: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_state()
	ProgressionManager.progression_data.changed.connect(update_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_state():
		
	var parent = get_parent()
	if parent is Node2D:
		if should_be_visible_if_flags_true:
				if check_flags():
					parent.visible=true
				else:
					parent.visible = false	
		else:
			if check_flags():
				parent.visible=false
			else:
					parent.visible = true
					
func check_flags()->bool:
	for flag in flags:
		if !ProgressionManager.get_flag(flag):
			return false
	return true				
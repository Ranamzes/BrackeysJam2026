extends Area2D
class_name LevelTransitionArea
@export var true_flags : Array[String]
@export_file("*.tscn") var scene_path:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_input_event(viewport: Node, event:InputEvent,shape_idx:int):
	if  event is InputEventMouseButton :
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && event.pressed :
			print("1")
			for flag in true_flags:
				if !ProgressionManager.get_flag(flag):
					return
			ScreenTransition.transition_to_scene(scene_path)	
			print("2")
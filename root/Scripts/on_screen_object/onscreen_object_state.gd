class_name OnScreenObjectState
extends Area2D

@export var transitions : Array[ObjectStateTransition]
@export var to_set_true: Array[String]
@export var to_set_false: Array[String]

func _ready() -> void:
	self.input_event.connect(_on_input_event)

func go_to(new_state : OnScreenObjectState) ->  void:
	for true_flag in to_set_true:
		ProgressionManager.set_flag(true_flag, true)
	for false_flag in to_set_false:
		ProgressionManager.set_flag(false_flag, false)
	self.visible = false
	new_state.visible = true


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		for transition in transitions:
			var new_state = transition.go_to_new_state()
			if new_state:
				return

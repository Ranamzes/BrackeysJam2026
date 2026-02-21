class_name OnScreenObjectState
extends Area2D

var transitions : Array[ObjectStateTransition]
@export var to_set_true: Array[String]
@export var to_set_false: Array[String]

func _ready() -> void:
	self.input_event.connect(_on_input_event)
	for child in get_children() :
		if child is ObjectStateTransition :
			transitions.append(child)
	if self.visible :
		set_flags()

func go_to(new_state : OnScreenObjectState) ->  void:
	new_state.set_flags()
	self.visible = false
	new_state.visible = true


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		for transition in transitions:
			var new_state = transition.go_to_new_state()
			if new_state:
				return

func set_flags() ->  void:
	for true_flag in to_set_true:
		ProgressionManager.set_flag(true_flag, true)
	for false_flag in to_set_false:
		ProgressionManager.set_flag(false_flag, false)
		
func do_transition(transition_name) -> bool:
	for transition in transitions :
		if transition.name == transition_name :
			transition.go_to_new_state(true)
			return true
	return false
	

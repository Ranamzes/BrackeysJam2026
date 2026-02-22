class_name ObjectWithStates
extends Node2D

@export var write_states: bool = false
@export var restore_states: bool = false
@export var do_transition_on_restore: bool = false

var states: Array[OnScreenObjectState]

func _ready() -> void:
	for state in get_children():
		state = state as OnScreenObjectState
		states.append(state)

	if restore_states:
		var transition_data: TransitionData = GlobalData.on_screen_objects_transitions.get(name)
		if transition_data != null:
			for state in states:
				if do_transition_on_restore:
					if transition_data.old_state_name == state.name:
						state.visible = true
					else:
						state.visible = false
				else:
					if transition_data.new_state_name == state.name:
						state.visible = true
					else:
						state.visible = false
			if do_transition_on_restore:
				var transition_succesfull: bool = get_state_by_name(transition_data.old_state_name).do_transition(transition_data.transition_name)
				if !transition_succesfull:
					printerr("Unable to perform transition!")
					printerr(transition_data._to_string())
					get_state_by_name(transition_data.old_state_name).visible = false
					get_state_by_name(transition_data.new_state_name).visible = true

	if write_states:
		for state in states:
			for transition in state.transitions:
				transition.transition.connect(_on_transition)

func get_state_by_name(state_name: String) -> OnScreenObjectState:
	for state in states:
		if state.name == state_name:
			return state
	return null

func _on_transition(transition: ObjectStateTransition) -> void:
	var transition_data: TransitionData = TransitionData.new()
	transition_data.old_state_name = transition.old_state.name
	transition_data.new_state_name = transition.new_state.name
	transition_data.transition_name = transition.name
	GlobalData.on_screen_objects_transitions.set(name, transition_data)

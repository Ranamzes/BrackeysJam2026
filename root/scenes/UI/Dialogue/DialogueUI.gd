class_name DialogueUI
extends CanvasLayer

signal finished

@onready var dialogue_label: RichTextLabel = $DialogueControl/DialoguePanel/DialogueLabel
@onready var panel: Panel = $DialogueControl/DialoguePanel
@onready var portrait_rect: TextureRect = $DialogueControl/DialoguePanel/Portrait
@onready var responses_menu: HBoxContainer = $DialogueControl/DialoguePanel/ResponsesMenu

var resource: DialogueResource
var temporary_game_states: Array = []
var is_waiting_for_input: bool = false

func _ready() -> void:
	hide()
	# Only connect the background control. If it covers the full screen/panel area,
	# it's enough. Clicks on the panel will bubble up to this control.
	$DialogueControl.gui_input.connect(_on_dialogue_control_gui_input)

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	if not is_node_ready():
		await ready

	print("DialogueUI: start called with title: ", title)

	# Since it's a fresh instance, we don't need heavy resets,
	# but let's ensure the label is empty during fade-in.
	dialogue_label.text = ""
	portrait_rect.hide()

	resource = dialogue_resource
	temporary_game_states = extra_game_states

	# 1. Get the first line BEFORE animation
	# This allows us to know if we should show the portrait/name before animating in
	var line = await DialogueManager.get_next_dialogue_line(resource, title, temporary_game_states)
	print("DialogueUI: get_next_dialogue_line (first) returned: ", line)

	if line == null:
		print("DialogueUI: No starting line found for title: ", title)
		_close_and_finish()
		return

	# Set portrait visibility based on the first line
	if line.character != "":
		portrait_rect.show()
	else:
		portrait_rect.hide()

	show()

	# 2. Play "open" animation
	if anim_player.has_animation("open"):
		anim_player.play("open")
		var anim_name = await anim_player.animation_finished
		while anim_name != "open":
			anim_name = await anim_player.animation_finished
	else:
		panel.modulate.a = 1.0

	while line != null:
		_display_line(line)

		# Wait for typing
		await dialogue_label.finished_typing

		if line.responses.size() > 0:
			show_responses(line.responses)
			var response = await self.response_selected
			line = await DialogueManager.get_next_dialogue_line(resource, response.next_id, temporary_game_states)
		else:
			is_waiting_for_input = true
			await self.advance_input
			is_waiting_for_input = false
			line = await DialogueManager.get_next_dialogue_line(resource, line.next_id, temporary_game_states)

	_close_and_finish()

func _display_line(line) -> void:
	if line.character != "":
		portrait_rect.show()
	else:
		portrait_rect.hide()

	dialogue_label.hide()
	dialogue_label.dialogue_line = line
	dialogue_label.show()
	dialogue_label.type_out()

func _close_and_finish() -> void:
	if anim_player.has_animation("close"):
		anim_player.play("close")
		await anim_player.animation_finished

	finished.emit()
	hide()

# Removed manual animate_open/animate_close functions as they are replaced by AnimationPlayer

signal advance_input
signal response_selected(response)

func _on_dialogue_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("DialogueUI: Click received via gui_input.")
		get_viewport().set_input_as_handled()
		_advance_conversation()

func _input(event: InputEvent) -> void:
	if not visible or is_queued_for_deletion(): return

	if event.is_action_pressed("ui_accept"):
		print("DialogueUI: Key received.")
		get_viewport().set_input_as_handled()
		_advance_conversation()

func _advance_conversation() -> void:
	if dialogue_label.get("is_typing"):
		dialogue_label.skip_typing()
	elif is_waiting_for_input:
		advance_input.emit()

func show_responses(responses: Array) -> void:
	# Clear old responses
	for child in responses_menu.get_children():
		child.queue_free()

	# Create new buttons
	for response in responses:
		if not response.is_allowed: continue
		var btn = Button.new()
		btn.text = response.text
		btn.pressed.connect(_on_response_pressed.bind(response))
		responses_menu.add_child(btn)

	# Focus first
	if responses_menu.get_child_count() > 0:
		responses_menu.get_child(0).grab_focus()

func _on_response_pressed(response) -> void:
	# Clear responses
	for child in responses_menu.get_children():
		child.queue_free()
	response_selected.emit(response)

func _exit_tree() -> void:
	# Failsafe if the node is deleted externally
	finished.emit()

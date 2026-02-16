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
		# Connect gui_input to handle clicks on the full-screen control
		$DialogueControl.gui_input.connect(_on_dialogue_control_gui_input)
		# Also connect the panel in case it consumes input
		panel.gui_input.connect(_on_dialogue_control_gui_input)
		# Ensure connections if any built-in signals need it
		# dialogue_label.finished_typing.connect(_on_dialogue_label_finished_typing)

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	print("DialogueUI: start called")
	resource = dialogue_resource
	temporary_game_states = extra_game_states

	show()
	# Play "open" animation
	if anim_player.has_animation("open"):
		anim_player.play("open")
		await anim_player.animation_finished
	else:
		# Fallback if animation missing
		panel.modulate.a = 1.0

	var line = await DialogueManager.get_next_dialogue_line(resource, title, temporary_game_states)
	while line != null:
		# 1. Update UI Elements
		if line.character != "":
			portrait_rect.show()
			# portrait_rect.texture = ...
		else:
			portrait_rect.hide()

		# 2. Update Text using DialogueLabel logic
		dialogue_label.hide() # Hide before typing
		dialogue_label.dialogue_line = line
		dialogue_label.show()
		dialogue_label.type_out()

		# Wait for typing to finish
		await dialogue_label.finished_typing

		# 3. Handle Responses
		if line.responses.size() > 0:
			show_responses(line.responses)
			var response = await self.response_selected
			line = await DialogueManager.get_next_dialogue_line(resource, response.next_id, temporary_game_states)
		else:
			# 4. Wait for player input to advance
			is_waiting_for_input = true
			await self.advance_input
			is_waiting_for_input = false
			line = await DialogueManager.get_next_dialogue_line(resource, line.next_id, temporary_game_states)

	# Play "close" animation
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
		_advance_conversation()

func _input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("ui_accept"):
		print("DialogueUI: Key received.")
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

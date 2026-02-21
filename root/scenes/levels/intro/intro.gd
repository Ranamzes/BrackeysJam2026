extends CanvasLayer

@onready var darkness_rect: TextureRect = $DarknessRect
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var eyes_container: Control = $EyesContainer
@onready var dialogue_label: RichTextLabel = $DialogueLabel

var main_menu_instance: Node = null

var current_line: DialogueLine = null
const DIALOGUE_RES = preload("res://root/resources/dialogue/monster.dialogue")

var eyes: Array[Node] = []
var eye_index = 0
var current_line_idx = -1
var eyes_per_line = [2, 2, 2, 2, 1]

var waiting_for_input = false
var sequence_finished = false

func _ready() -> void:
	darkness_rect.modulate = Color(1, 1, 1, 0)
	darkness_rect.scale = Vector2(0.1, 0.1)

	smoke_particles.emitting = true
	dialogue_label.text = ""

	for eye in eyes_container.get_children():
		eye.modulate.a = 0
		eyes.append(eye)
	start_sequence()

func start_sequence():
	# 1. Expand darkness and fade in
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkness_rect, "scale", Vector2(2.5, 2.5), 1.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(darkness_rect, "modulate", Color(1, 1, 1, 1), 0.3)

	await tween.finished

	# 2. Delete Main Menu
	if main_menu_instance and is_instance_valid(main_menu_instance):
		main_menu_instance.queue_free()

	# 3. Start Dialogue and Eye setup
	start_next_dialogue_line()

func show_next_eye():
	if eye_index < eyes.size():
		var eye = eyes[eye_index]
		if eye.has_method("open_eye"):
			eye.open_eye()
		eye_index += 1

func start_next_dialogue_line():
	if current_line == null:
		current_line = await DialogueManager.get_next_dialogue_line(DIALOGUE_RES, "start")
	else:
		current_line = await DialogueManager.get_next_dialogue_line(DIALOGUE_RES, current_line.next_id)

	if current_line != null:
		dialogue_label.dialogue_line = current_line
		dialogue_label.type_out()

		if not dialogue_label.finished_typing.is_connected(_on_typing_finished):
			dialogue_label.finished_typing.connect(_on_typing_finished)

		waiting_for_input = false
		current_line_idx += 1

		# Open a fixed number of eyes per line according to our plan
		var eyes_to_open = 0
		if current_line_idx < eyes_per_line.size():
			eyes_to_open = eyes_per_line[current_line_idx]

		var cumulative_delay = 0.0
		for i in range(eyes_to_open):
			if i == 0:
				show_next_eye()
			else:
				cumulative_delay += randf_range(0.8, 1.3)
				get_tree().create_timer(cumulative_delay).timeout.connect(show_next_eye)
	else:
		# End sequence, wait for final click
		sequence_finished = true
		waiting_for_input = true
		dialogue_label.text = ""

		# Make all eyes look at the player
		for eye in eyes:
			if eye.has_method("look_at_player"):
				eye.look_at_player()

func _on_typing_finished() -> void:
	waiting_for_input = true

func _input(event: InputEvent) -> void:
	# Progress dialogue on left mouse click or any potential 'interact' action if defined
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if waiting_for_input:
			if sequence_finished:
				# Next level transition
				ProgressionManager.set_flag("intro", true)
				set_process_input(false)
				ScreenTransition.transition_to_scene("res://main_level.tscn")
				# Wait for screen to darken before removing the canvas layer
				await ScreenTransition.transition_halfway
				queue_free()
			else:
				# Go to next line
				start_next_dialogue_line()
		elif not waiting_for_input and dialogue_label != null and dialogue_label.dialogue_line != null:
			# Skip typing and show full line immediately
			dialogue_label.skip_typing()
			waiting_for_input = true

class_name SpongeMinigameManager
extends Node

signal sequence_completed
signal sequence_failed

@export var correct_sequence: Array[StringName] = [&"red", &"red", &"green", &"red", &"green", &"green", &"red", &"red"]


var current_index: int = 0

@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var failure_sound: AudioStreamPlayer = $FailureSound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var star_particles: CPUParticles2D = get_parent().get_node("ParticlesLayer/Sponges/StarParticles")
@onready var flying_path: Path2D = get_parent().get_node("FlyingPath")


func _ready() -> void:
	if flying_path:
		print("FlyingPath connected. Points in curve: ", flying_path.curve.point_count)
	else:
		printerr("FlyingPath node NOT FOUND in SpongeMinigame!")

	if star_particles:
		star_particles.emitting = false

func _process(_delta: float) -> void:
	var hovering = false
	var mouse_pos = get_viewport().get_mouse_position()

	# Reverse order to check top-most sponges first
	var sponges = get_tree().get_nodes_in_group(&"sponges")
	sponges.reverse()

	for child in sponges:
		if child is SpongeComponent:
			var local_pos = child.make_input_local(InputEventMouseMotion.new()).position
			# make_input_local needs an event to get the position, or we can just convert manually
			local_pos = mouse_pos - child.global_position
			if child.get_rect().has_point(local_pos):
				hovering = true
				break

	Cursor.set_hovering(hovering)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var sponges = get_tree().get_nodes_in_group(&"sponges")
		# Sponges in SpongeSurface (layer 3) should be checked first
		sponges.reverse()

		for child in sponges:
			if child is SpongeComponent:
				var local_pos = event.position
				if child.get_rect().has_point(local_pos):
					child.handle_click(local_pos)
					_on_sponge_clicked(child.id)
					get_viewport().set_input_as_handled()
					break

func _on_sponge_clicked(sponge_id: StringName) -> void:
	if not ProgressionManager.get_flag("levers_solved"):
		if failure_sound:
			failure_sound.play()
		current_index = 0
		print("Prerequisite 'levers_solved' not met. Sequence reset.")
		return

	if click_sound:
		click_sound.play()

	print("Clicked: ", sponge_id, " Expected: ", str(correct_sequence[current_index]) if current_index < correct_sequence.size() else "None")

	if current_index < correct_sequence.size():
		if sponge_id == correct_sequence[current_index]:
			current_index += 1
			if current_index == correct_sequence.size():
				_on_success()
		else:
			_on_failure()

func _on_success() -> void:
	if success_sound:
		success_sound.play()

	AudioService.play_sound("res://root/assets/sounds/sponges_wow.wav", &"SFX")

	current_index = 0
	ProgressionManager.set_flag("sponges_solved", true)
	sequence_completed.emit()
	print("Sponge sequence completed! Spawning stars...")
	_spawn_stars_and_update_inventory()

func _spawn_stars_and_update_inventory() -> void:
	var soap_full = load("res://root/assets/items/soap_full.tres")
	var soap_stars = load("res://root/assets/items/soap_stars.tres")

	var curve = flying_path.curve if flying_path and flying_path.curve.point_count > 0 else null

	if star_particles and curve:
		# Snap emitter to first point of path before emitting, so trail starts there
		var start_local = curve.get_point_position(0)
		star_particles.global_position = flying_path.to_global(start_local)
		star_particles.restart()
		star_particles.emitting = true

		var comet_tween = create_tween()
		comet_tween.tween_method(
			func(t: float):
				var local_pos = curve.sample_baked(t * curve.get_baked_length())
				star_particles.global_position = flying_path.to_global(local_pos),
			0.0, 1.0, 1.5
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

		comet_tween.tween_callback(func(): star_particles.emitting = false)
		comet_tween.tween_interval(star_particles.lifetime)
		comet_tween.tween_callback(func(): _perform_item_swap(soap_full, soap_stars))
	else:
		# Fallback if no curve
		_perform_item_swap(soap_full, soap_stars)


func _perform_item_swap(old_item: ItemData, new_item: ItemData) -> void:
	var inventory = GlobalData.player_inventory
	if inventory:
		var slot = inventory.get_item_slot(old_item)
		if slot:
			slot.item = new_item
			inventory.InventoryUpdated.emit()
			ProgressionManager.set_flag("soap_stars_picked_up", true)
			print("Swapped soap_full to soap_stars and set soap_stars_picked_up flag.")


func _on_failure() -> void:
	if failure_sound:
		failure_sound.play()
	current_index = 0
	sequence_failed.emit()
	print("Sponge sequence failed, resetting...")

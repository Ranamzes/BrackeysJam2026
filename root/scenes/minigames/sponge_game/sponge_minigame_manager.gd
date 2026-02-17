class_name SpongeMinigameManager
extends Node

signal sequence_completed
signal sequence_failed

@export var correct_sequence: Array[StringName] = [&"red", &"red", &"green", &"red", &"green", &"green", &"red", &"red"]

var current_index: int = 0

@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var failure_sound: AudioStreamPlayer = $FailureSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

func _ready() -> void:
	# Connect to all sponges in the scene that are in the "sponges" group
	for child in get_tree().get_nodes_in_group(&"sponges"):
		if child.has_signal(&"sponge_clicked"):
			child.connect(&"sponge_clicked", _on_sponge_clicked)

func _on_sponge_clicked(sponge_id: StringName) -> void:
	if click_sound:
		click_sound.play()

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
	current_index = 0
	ProgressionManager.set_flag("sponge_completed", true)
	sequence_completed.emit()
	print("Sponge sequence completed!")

func _on_failure() -> void:
	if failure_sound:
		failure_sound.play()
	current_index = 0
	sequence_failed.emit()
	print("Sponge sequence failed, resetting...")

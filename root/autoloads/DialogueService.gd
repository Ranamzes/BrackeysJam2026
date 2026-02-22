extends Node

# The unique instance of the DialogueUI
var current_dialogue_ui: DialogueUI

# Preload the scene to instantiate it when needed
const DIALOGUE_SCENE = preload("res://root/scenes/UI/Dialogue/DialogueUI.tscn")

var is_dialogue_active: bool = false

func start_dialogue(resource: DialogueResource, title: String, extra_game_states: Array = [], portrait_texture: Texture2D = null, portrait_scene: PackedScene = null) -> void:
	print("DialogueService: start_dialogue called with title: ", title)

	if is_dialogue_active:
		print("DialogueService: Dialogue already active, ignoring.")
		return

	is_dialogue_active = true

	# Always recreate the UI for a perfectly clean state
	if is_instance_valid(current_dialogue_ui):
		current_dialogue_ui.queue_free()

	print("DialogueService: Instantiating fresh DialogueUI...")
	current_dialogue_ui = DIALOGUE_SCENE.instantiate()
	current_dialogue_ui.layer = 11
	get_tree().root.add_child(current_dialogue_ui)
	current_dialogue_ui.finished.connect(_on_dialogue_finished)

	# Wait one frame or for 'ready' to ensure @onready variables are populated
	if not current_dialogue_ui.is_node_ready():
		await current_dialogue_ui.ready

	print("DialogueService: Calling UI.start()...")
	current_dialogue_ui.start(resource, title, extra_game_states, portrait_texture, portrait_scene)


func _on_dialogue_finished() -> void:
	is_dialogue_active = false
	if is_instance_valid(current_dialogue_ui):
		current_dialogue_ui.queue_free()

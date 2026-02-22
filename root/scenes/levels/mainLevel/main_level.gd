extends Node2D

@onready var door: Sprite2D = $BackgroundContainer/Door

@export_group("Dialogue Settings")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "open_door"
@export var portrait_texture: Texture2D
@export var portrait_scene: PackedScene

func _ready() -> void:
	var hud = $Hud
	AudioService.play_music(preload("res://root/assets/music/calming.mp3"), &"Music", 1.0, -10)
	if ProgressionManager.get_flag("level_1_visited"):
		hud.right_scene = "uid://dtxkforlylqrn"
	hud.update_navigation()

	if ProgressionManager.get_flag("door_1_opened"):
		# Door already was revealed, show it immediately and skip sequence
		door.modulate.a = 1.0
		door.show()
	else:
		# First time: hide door and start the 1.5s delay sequence
		door.modulate.a = 0
		door.hide()
		get_tree().create_timer(1.0).timeout.connect(_on_sequence_start)

	# If arriving after quest_2 (flower delivered), trigger quest_2b dialogue
	if ProgressionManager.get_flag("quest_2_arrived") and not ProgressionManager.get_flag("planet_quest"):
		ProgressionManager.set_flag("quest_2_arrived", false)
		get_tree().create_timer(1.0).timeout.connect(_on_quest_2b_start)


func _on_quest_2b_start() -> void:
	DialogueService.start_dialogue(dialogue_resource, "quest_2b", [self], portrait_texture, portrait_scene)


func _on_sequence_start() -> void:
	# Trigger dialogue directly passing [self] so it can call reveal_door()
	DialogueService.start_dialogue(dialogue_resource, dialogue_start, [self], portrait_texture, portrait_scene)


func reveal_door(door_node_name: String = "Door") -> void:
	# Set progression flag
	ProgressionManager.set_flag("door_1_opened", true)

	var target_door: Node = $BackgroundContainer.get_node_or_null(door_node_name)
	if target_door == null:
		push_warning("reveal_door: node '%s' not found in BackgroundContainer" % door_node_name)
		return

	target_door.show()
	var tween = create_tween()
	tween.tween_property(target_door, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE)

	# Play door sound
	var sfx = load("res://root/scenes/levels/mainLevel/door_open.wav")
	AudioService.play_sound(sfx, &"SFX")

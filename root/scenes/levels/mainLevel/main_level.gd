extends Node2D

@onready var door: Sprite2D = $Door

@export_group("Dialogue Settings")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "open_door"
@export var portrait_texture: Texture2D
@export var portrait_scene: PackedScene

func _ready() -> void:
	if ProgressionManager.get_flag("door_1_opened"):
		# Door already was revealed, show it immediately and skip sequence
		door.modulate.a = 1.0
		door.show()
	else:
		# First time: hide door and start the 1.5s delay sequence
		door.modulate.a = 0
		door.hide()
		get_tree().create_timer(1.0).timeout.connect(_on_sequence_start)


func _on_sequence_start() -> void:
	# Trigger dialogue directly passing [self] so it can call reveal_door()
	DialogueService.start_dialogue(dialogue_resource, dialogue_start, [self], portrait_texture, portrait_scene)


func reveal_door() -> void:
	# Set progression flag
	ProgressionManager.set_flag("door_1_opened", true)

	door.show()
	var tween = create_tween()
	tween.tween_property(door, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE)

	# Play door sound
	var sfx = load("res://root/scenes/levels/mainLevel/door_open.wav")
	AudioService.play_sound(sfx, &"SFX")

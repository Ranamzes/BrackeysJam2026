extends Control

@onready var mouth: AnimatedSprite2D = %Mouth

func _ready() -> void:
	await get_tree().process_frame
	_connect_to_dialogue()

func _connect_to_dialogue() -> void:
	# Find DialogueUI in root children
	for child in get_tree().root.get_children():
		if child is DialogueUI:
			var label = child.get_node_or_null("%DialogueLabel")
			if label:
				label.started_typing.connect(_on_started_typing)
				label.finished_typing.connect(_on_finished_typing)
				label.skipped_typing.connect(_on_finished_typing)
			break

func _on_started_typing() -> void:
	if mouth:
		mouth.play("talking")

func _on_finished_typing() -> void:
	if mouth:
		mouth.play("idle")

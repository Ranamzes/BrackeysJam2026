@tool
class_name SpongeComponent
extends TextureButton

signal sponge_clicked(id: StringName)

@export var id: StringName
@export var normal_texture: Texture2D:
	set(value):
		normal_texture = value
		_update_visuals()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Enable mouse resizing in the editor and game
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_SCALE

	_update_visuals()

	if not Engine.is_editor_hint():
		pressed.connect(_on_pressed)

func _update_visuals() -> void:
	if normal_texture:
		texture_normal = normal_texture
	# Centering pivot for squish animation
	pivot_offset = size / 2

func _on_pressed() -> void:
	sponge_clicked.emit(id)
	if animation_player:
		animation_player.play(&"squish")

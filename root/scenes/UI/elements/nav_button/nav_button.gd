@tool
extends TextureButton

class_name NavButton


@export var tint_color: Color = Color(0.8, 0.8, 0.8)
@export var button_size: Vector2 = Vector2(0, 0):
	set(value):
		button_size = value
		custom_minimum_size = value
		_update_styling()


@export var nav_rotation: float = 0.0:
	set(value):
		nav_rotation = value
		_update_styling()


var _frames_to_update: int = 10
var _is_updating: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		pressed.connect(on_pressed)
		button_down.connect(_on_button_down)
		button_up.connect(_on_button_up)

	custom_minimum_size = button_size
	_update_styling()

	item_rect_changed.connect(_update_styling)
	visibility_changed.connect(_update_styling)


func _process(_delta: float) -> void:
	if _frames_to_update > 0:
		_update_styling()
		_frames_to_update -= 1
	elif not Engine.is_editor_hint():
		set_process(false)


func _update_styling() -> void:
	if _is_updating or not is_inside_tree():
		return

	_is_updating = true

	# Rotation & Pivot
	pivot_offset = size / 2.0
	rotation_degrees = nav_rotation

	_is_updating = false


func _on_button_down() -> void:
	self_modulate = tint_color


func _on_button_up() -> void:
	self_modulate = Color.WHITE


func on_pressed():
	if not Engine.is_editor_hint():
		var stream_player: Node = get_node_or_null("StreamPlayerComponent")
		if stream_player and stream_player.has_method("play_random"):
			stream_player.call("play_random")

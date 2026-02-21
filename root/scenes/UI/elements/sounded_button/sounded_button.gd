@tool
extends Control

class_name SoundedButton

signal pressed

@export_group("Textures")
@export var normal_texture: Texture2D:
	set(value):
		if normal_texture != value:
			normal_texture = value
			_request_update()
@export var hover_texture: Texture2D:
	set(value):
		if hover_texture != value:
			hover_texture = value
			_request_update()
@export var pressed_texture: Texture2D:
	set(value):
		if pressed_texture != value:
			pressed_texture = value
			_request_update()

@export_group("Text")
@export var text: String = "Placeholder":
	set(value):
		if text != value:
			text = value
			_request_update()

@export var normal_color: Color = Color.WHITE:
	set(value):
		if normal_color != value:
			normal_color = value
			_request_update()

@export var hover_color: Color = Color.RED

@export var disabled: bool = false:
	set(value):
		if disabled != value:
			disabled = value
			_request_update()

@export_subgroup("Font Overrides")
@export var custom_font: Font:
	set(value):
		if custom_font != value:
			custom_font = value
			_request_update()
@export var font_size: int = 64:
	set(value):
		if font_size != value:
			font_size = value
			_request_update()

@export_group("Layout")
@export var texture_offset: Vector2 = Vector2.ZERO:
	set(value):
		if texture_offset != value:
			texture_offset = value
			_request_update()

@export var text_offset: Vector2 = Vector2.ZERO:
	set(value):
		if text_offset != value:
			text_offset = value
			_request_update()

@export var text_rotation: float = 0.0:
	set(value):
		if text_rotation != value:
			text_rotation = value
			_request_update()

@export_group("Click Mask")
@export_range(0, 1.0) var click_mask_threshold: float = 0.5

@export_group("sound")
@export var sound_streams:Array[AudioStream]
@onready var stream_player_component: StreamPlayerComponent = %StreamPlayerComponent
var _needs_update := false

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
	else:
		set_process(false)
		resized.connect(_request_update)

	var btn = get_node_or_null("Button")
	if btn:
		if not btn.pressed.is_connected(_on_btn_pressed):
			btn.pressed.connect(_on_btn_pressed)
		if not btn.mouse_entered.is_connected(_on_mouse_entered):
			btn.mouse_entered.connect(_on_mouse_entered)
		if not btn.mouse_exited.is_connected(_on_mouse_exited):
			btn.mouse_exited.connect(_on_mouse_exited)

	_do_update_ui()
	if(sound_streams!=null and sound_streams.size()>0):
		stream_player_component.streams = sound_streams

func _process(_delta: float) -> void:
	if _needs_update:
		_do_update_ui()


func _request_update() -> void:
	if not is_inside_tree() or not is_node_ready():
		return
	_needs_update = true
	# In runtime, use deferred to avoid layout flickering
	if not Engine.is_editor_hint():
		_do_update_ui.call_deferred()


func _do_update_ui() -> void:
	_needs_update = false
	if not is_inside_tree() or not is_node_ready():
		return

	var btn: TextureButton = get_node_or_null("Button")
	var container: Control = get_node_or_null("TextContainer")
	var lbl: Label = get_node_or_null("TextContainer/Label")

	if btn:
		if btn.texture_normal != normal_texture: btn.texture_normal = normal_texture
		if btn.texture_pressed != pressed_texture: btn.texture_pressed = pressed_texture
		if btn.texture_hover != hover_texture: btn.texture_hover = hover_texture
		if btn.position != texture_offset: btn.position = texture_offset
		if btn.disabled != disabled: btn.disabled = disabled
		if btn.texture_normal and not btn.texture_click_mask:
			_update_click_mask()

	if lbl:
		if lbl.text != text: lbl.text = text
		if lbl.modulate != normal_color: lbl.modulate = normal_color

		# Apply font overrides
		if custom_font:
			lbl.add_theme_font_override("font", custom_font)
		else:
			lbl.remove_theme_font_override("font")

		if font_size > 0:
			lbl.add_theme_font_size_override("font_size", font_size)
		else:
			lbl.remove_theme_font_size_override("font_size")

	if container:
		# Use get_rect().size instead of size to be safer in editor
		var control_size = get_rect().size
		var target_pos = (control_size / 2.0) + texture_offset + text_offset
		if container.position != target_pos:
			container.position = target_pos
		if container.rotation_degrees != text_rotation:
			container.rotation_degrees = text_rotation


func _update_click_mask() -> void:
	var btn: TextureButton = get_node_or_null("Button")
	if btn and normal_texture:
		var image: Image = normal_texture.get_image()
		if image:
			var bitmap: BitMap = BitMap.new()
			bitmap.create_from_image_alpha(image, click_mask_threshold)
			btn.texture_click_mask = bitmap

func _on_btn_pressed() -> void:
	pressed.emit()
	if not Engine.is_editor_hint():
		var player = get_node_or_null("StreamPlayerComponent")
		if player:
			player.play_random()


func _on_mouse_entered() -> void:
	if Engine.is_editor_hint(): return
	var lbl = get_node_or_null("TextContainer/Label")
	if lbl:
		var tween = create_tween()
		tween.tween_property(lbl, "modulate", hover_color, 0.1)


func _on_mouse_exited() -> void:
	if Engine.is_editor_hint(): return
	var lbl = get_node_or_null("TextContainer/Label")
	if lbl:
		var tween = create_tween()
		tween.tween_property(lbl, "modulate", normal_color, 0.1)

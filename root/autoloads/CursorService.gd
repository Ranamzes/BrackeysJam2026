extends Node

## Manages software mouse cursors and their states to fix Web build refresh issues.
class_name MouseCursorService

@export var cursor_scale: float = 0.5

# Preload resources
const CURSOR_NORMAL_RES = preload("res://root/assets/atlases/ui_buttons.sprites/cursor.tres")
const CURSOR_CLICK_RES = preload("res://root/assets/atlases/ui_buttons.sprites/cursor_click.tres")
const POINTER_NORMAL_RES = preload("res://root/assets/atlases/ui_buttons.sprites/pointer_rest.tres")
const POINTER_CLICK_RES = preload("res://root/assets/atlases/ui_buttons.sprites/pointer_click.tres")

# Cached resized textures
var _cursor_normal: ImageTexture
var _cursor_click: ImageTexture
var _pointer_normal: ImageTexture
var _pointer_click: ImageTexture

# Software cursor nodes
var _canvas_layer: CanvasLayer
var _sprite: Sprite2D
var _is_pressed: bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

	# Pre-cache resized textures
	_cache_textures()

	# Create software cursor hierarchy
	_setup_software_cursor()

	# Hide the hardware cursor
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_is_pressed = event.pressed


func _process(_delta: float) -> void:
	if not _sprite: return

	# Follow mouse position in viewport space
	_sprite.global_position = get_viewport().get_mouse_position()

	# Update texture based on shape and state
	_update_cursor_texture()


## Creates a top-level CanvasLayer and Sprite2D for the cursor.
func _setup_software_cursor() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 128 # Ensure it's above all UI
	_canvas_layer.name = &"CursorLayer"
	add_child(_canvas_layer)

	_sprite = Sprite2D.new()
	_sprite.name = &"SoftwareCursor"
	_sprite.centered = false # Our cursors are top-left aligned in frames
	_canvas_layer.add_child(_sprite)

	# Initial texture
	_sprite.texture = _cursor_normal


## Updates the sprite texture based on the current cursor shape and click state.
func _update_cursor_texture() -> void:
	var shape = Input.get_current_cursor_shape()

	match shape:
		Input.CURSOR_POINTING_HAND:
			_sprite.texture = _pointer_click if _is_pressed else _pointer_normal
		_:
			_sprite.texture = _cursor_click if _is_pressed else _cursor_normal


## Caches resized versions of the cursor textures.
func _cache_textures() -> void:
	_cursor_normal = _get_scaled_texture(CURSOR_NORMAL_RES)
	_cursor_click = _get_scaled_texture(CURSOR_CLICK_RES)
	_pointer_normal = _get_scaled_texture(POINTER_NORMAL_RES)
	_pointer_click = _get_scaled_texture(POINTER_CLICK_RES)


## Resizes a texture based on cursor_scale and returns an ImageTexture.
func _get_scaled_texture(atlas_tex: AtlasTexture) -> ImageTexture:
	var img: Image = atlas_tex.get_image()
	var new_size: Vector2i = Vector2i(Vector2(img.get_size()) * cursor_scale)
	if new_size.x > 0 and new_size.y > 0:
		img.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)

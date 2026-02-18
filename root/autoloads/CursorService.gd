extends Node

## Manages custom mouse cursors and their states (rest/click).
class_name MouseCursorService

@export var cursor_scale: float = 0.5

# Preload resources for better performance
const CURSOR_NORMAL_RES = preload("res://root/assets/atlases/ui_buttons.sprites/cursor.tres")
const CURSOR_CLICK_RES = preload("res://root/assets/atlases/ui_buttons.sprites/cursor_click.tres")
const POINTER_NORMAL_RES = preload("res://root/assets/atlases/ui_buttons.sprites/pointer_rest.tres")
const POINTER_CLICK_RES = preload("res://root/assets/atlases/ui_buttons.sprites/pointer_click.tres")

# Cached resized textures
var _cursor_normal: ImageTexture
var _cursor_click: ImageTexture
var _pointer_normal: ImageTexture
var _pointer_click: ImageTexture

func _ready() -> void:
	# Pre-cache resized textures
	_cache_textures()
	# Set initial default cursors
	_update_cursors(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_update_cursors(event.pressed)


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


## Updates the custom mouse cursors for arrow and pointing hand shapes.
func _update_cursors(is_pressed: bool) -> void:
	var arrow_texture: Texture2D = _cursor_click if is_pressed else _cursor_normal
	var pointer_texture: Texture2D = _pointer_click if is_pressed else _pointer_normal

	# CURSOR_ARROW is the default cursor
	Input.set_custom_mouse_cursor(arrow_texture, Input.CURSOR_ARROW)

	# CURSOR_POINTING_HAND is used for buttons and interactive elements
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND)

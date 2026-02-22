extends Node

## Manages software mouse cursors and their states to fix Web build refresh issues.
class_name MouseCursorService

var _is_hovering_forced: bool = false

func set_hovering(value: bool) -> void:
	_is_hovering_forced = value


@export var cursor_scale: float = 0.5
## Offset (in pixels, relative to cursor top-left) to position the item icon at the pupil center
@export var item_icon_offset: Vector2 = Vector2(35, 50)
## Scale applied to the item icon so it fits inside the eye pupil
@export var item_icon_scale: float = 0.058

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
var _item_icon_sprite: Sprite2D
var _is_pressed: bool = false

## Tracks whether the eye is currently open (cursor_normal texture is shown)
var _eye_is_open: bool = false


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
	var mouse_pos = get_viewport().get_mouse_position()
	_sprite.global_position = mouse_pos

	# Update texture based on shape and state
	_update_cursor_texture()

	# Position item icon at pupil center
	if _item_icon_sprite:
		_item_icon_sprite.global_position = mouse_pos + item_icon_offset


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

	# Item icon sprite — shown inside the pupil when eye is open
	_item_icon_sprite = Sprite2D.new()
	_item_icon_sprite.name = &"ItemIconCursor"
	_item_icon_sprite.centered = true
	_item_icon_sprite.visible = false
	_item_icon_sprite.scale = Vector2.ONE * item_icon_scale
	_canvas_layer.add_child(_item_icon_sprite)

	# Initial texture (Closed eye by default)
	_sprite.texture = _cursor_click


## Updates the sprite texture based on the current cursor shape and interactivity.
func _update_cursor_texture() -> void:
	var shape = Input.get_current_cursor_shape()
	var in_dialogue_area = _is_mouse_over_dialogue_texture()
	var is_hovering = _is_mouse_over_interactive() or in_dialogue_area or shape == Input.CURSOR_POINTING_HAND or _is_hovering_forced


	# Logic:
	# - Default (No Hover): Closed eye (cursor_click)
	# - Hovering: Open eye (cursor_normal)
	# - Pressing while hovering: Closed eye (cursor_click)
	if is_hovering:
		_sprite.texture = _cursor_click if _is_pressed else _cursor_normal
		_eye_is_open = not _is_pressed
	else:
		_sprite.texture = _cursor_click
		_eye_is_open = false

	# Show item icon inside the pupil when eye is open and an item is selected
	_update_item_icon()


func _update_item_icon() -> void:
	if not _item_icon_sprite: return

	var selected: ItemSlotUI = GlobalData.selected_slot
	if _eye_is_open and selected and selected.inventory_slot and selected.inventory_slot.item:
		_item_icon_sprite.texture = selected.inventory_slot.item.icon
		_item_icon_sprite.visible = true
	else:
		_item_icon_sprite.visible = false


## Checks if the mouse is currently over a pickable physics object.
func _is_mouse_over_interactive() -> bool:
	var world_space = get_viewport().find_world_2d()
	if not world_space: return false

	var space_state = world_space.direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()

	# Create query
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	# Use small collision margin if needed, but point query is usually enough

	var results = space_state.intersect_point(query)
	for result in results:
		var collider = result.collider
		if collider is CollisionObject2D and collider.input_pickable and collider.is_visible_in_tree():
			return true

	return false


## Specialized check for DialogueUI texture (pixel-perfect)
func _is_mouse_over_dialogue_texture() -> bool:
	# Use DialogueService reference directly for reliability
	var dialogue_ui = DialogueService.current_dialogue_ui
	if not is_instance_valid(dialogue_ui) or not dialogue_ui.visible:
		return false

	var bg_rect: TextureRect = dialogue_ui.find_child("Background", true, false)
	if not bg_rect or not bg_rect.is_visible_in_tree():
		return false

	var mouse_pos = bg_rect.get_local_mouse_position()
	var texture = bg_rect.texture
	if not texture: return false

	var rect = Rect2(Vector2.ZERO, bg_rect.size)
	if not rect.has_point(mouse_pos):
		return false

	# Pixel-perfect check
	var image = texture.get_image()
	if not image: return true

	# Scale mouse pos to image size
	var tex_pos = mouse_pos * (Vector2(image.get_size()) / bg_rect.size)

	if tex_pos.x < 0 or tex_pos.y < 0 or tex_pos.x >= image.get_width() or tex_pos.y >= image.get_height():
		return false

	return image.get_pixelv(Vector2i(tex_pos)).a > 0.1


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

@tool
class_name DialogueTrigger
extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@export var portrait_texture: Texture2D

## Optional portrait scene (PackedScene) to show in the Dialogue UI.
## Takes precedence over portrait_texture if assigned.
@export var portrait_scene: PackedScene

## Optional list of conditional dialogue paths. The first one that meets its conditions will be used.
@export var variants: Array[DialogueVariant] = []


@export_group("Interaction Settings")
## If enabled, clicks on transparent pixels will be ignored using a generated collision polygon.
@export var pixel_perfect: bool = true:
	set(value):
		pixel_perfect = value
		if auto_setup: _perform_auto_setup()

## Padding (in pixels) added to the texture outline for easier clicking.
@export var collision_padding: float = 24.0:
	set(value):
		collision_padding = value
		if auto_setup: _perform_auto_setup()

## Higher values reduce the number of polygon vertices (good for performance).
@export var simplification_factor: float = 1.0:
	set(value):
		simplification_factor = value
		if auto_setup: _perform_auto_setup()

## If enabled and no CollisionShape2D exists, it will be created based on parent Sprite/Texture size.
@export var auto_setup: bool = true:
	set(value):
		auto_setup = value
		if auto_setup: _perform_auto_setup()

func _ready() -> void:
	# Ensure the area is pickable so it receives input events
	input_pickable = true

	if auto_setup:
		_perform_auto_setup()


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if Engine.is_editor_hint(): return # Don't trigger in editor

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("DialogueTrigger: [", name, "] CLICK DETECTED. Pixel perfect: ", pixel_perfect)

		# If pixel_perfect is on but no polygon was generated (fallback), check manually
		if pixel_perfect:
			var has_poly = false
			for child in get_children():
				if child is CollisionPolygon2D:
					has_poly = true
					break

			if not has_poly:
				var local_pos = get_local_mouse_position()
				if not _check_pixel_opaque(local_pos):
					print("DialogueTrigger: [", name, "] CLICK IGNORED (Manual pixel check failed at ", local_pos, ")")
					return
				else:
					print("DialogueTrigger: [", name, "] CLICK ACCEPTED (Manual pixel check passed)")
			else:
				print("DialogueTrigger: [", name, "] CLICK ACCEPTED (Via Polygon)")

		print("DialogueTrigger: [", name, "] Triggering dialogue start...")
		start_dialogue()

func _perform_auto_setup() -> void:
	print("DialogueTrigger: [", name, "] Performing auto-setup...")
	# 1. Handle mouse filter for Control parents
	var parent = get_parent()
	if not parent:
		print("DialogueTrigger: [", name, "] No parent found for auto-setup.")
		return

	if parent is Control and parent.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		parent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("DialogueTrigger: Set parent %s mouse_filter to IGNORE" % parent.name)

	# 2. Check if we already have a collision child
	for child in get_children():
		if child.name.begins_with("AutoCollision"):
			child.free()

	var size := Vector2.ZERO

	if parent is Sprite2D and parent.texture:
		size = parent.texture.get_size()
	elif parent is AnimatedSprite2D and parent.sprite_frames:
		var anim = parent.animation
		var frame = parent.frame
		var tex = parent.sprite_frames.get_frame_texture(anim, frame)
		if tex: size = tex.get_size()
	elif parent is TextureRect and parent.texture:
		size = parent.size
	elif parent is Control:
		size = parent.size

	if size != Vector2.ZERO:
		if pixel_perfect:
			_setup_pixel_perfect_collision(parent)
		else:
			_setup_rect_collision(parent, size)

func _setup_rect_collision(parent: Node, size: Vector2) -> void:
	var shape_node = CollisionShape2D.new()
	shape_node.name = "AutoCollisionShape"
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = size
	shape_node.shape = rect_shape

	# Center it if parent is Sprite2D (usually centered)
	if parent is Sprite2D and parent.centered:
		shape_node.position = Vector2.ZERO
	else:
		shape_node.position = size / 2.0

	add_child(shape_node)

	# In editor, make it visible and persistent
	if Engine.is_editor_hint():
		shape_node.owner = get_tree().edited_scene_root

	print("DialogueTrigger: Auto-created rect collision for ", parent.name)

func _setup_pixel_perfect_collision(parent: Node) -> void:
	var texture: Texture2D = null
	if parent is Sprite2D: texture = parent.texture
	elif parent is AnimatedSprite2D and parent.sprite_frames:
		texture = parent.sprite_frames.get_frame_texture(parent.animation, parent.frame)
	elif parent is TextureRect: texture = parent.texture

	if not texture:
		print("DialogueTrigger: No texture found for pixel-perfect setup on ", parent.name)
		return

	var image = texture.get_image()
	if not image: return

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)

	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture.get_size()))

	for poly in polygons:
		# 1. Apply padding
		if collision_padding > 0:
			var offset_polys = Geometry2D.offset_polygon(poly, collision_padding)
			if offset_polys.size() > 0:
				poly = offset_polys[0] # Take the main expanded shape

		# 2. Simplify for Web performance (Disabled due to parser error: simplify_polyline not found)
		# Simplification removed to ensure compatibility across versions.

		var poly_node = CollisionPolygon2D.new()
		poly_node.name = "AutoCollisionPolygon"

		# Offset to match sprite centering
		var offset = Vector2.ZERO
		if parent is Sprite2D and parent.centered:
			offset = - texture.get_size() / 2.0

		var offset_poly = PackedVector2Array()
		for p in poly:
			offset_poly.append(p + offset)

		poly_node.polygon = offset_poly
		add_child(poly_node)

		if Engine.is_editor_hint():
			poly_node.owner = get_tree().edited_scene_root

	print("DialogueTrigger: Auto-created pixel-perfect collision for ", parent.name, " (Polygons: ", polygons.size(), ")")

func _check_pixel_opaque(click_pos: Vector2) -> bool:
	var parent = get_parent()
	var texture: Texture2D = null

	if parent is Sprite2D:
		texture = parent.texture
	elif parent is AnimatedSprite2D:
		texture = parent.sprite_frames.get_frame_texture(parent.animation, parent.frame)
	elif parent is TextureRect:
		texture = parent.texture

	if not texture: return true # Fallback to opaque if no texture found

	var image = texture.get_image()
	if not image: return true

	# Convert click_pos (local to Area2D) to texture coordinates
	# This simple math assumes the Area2D is centered/aligned with the sprite
	var tex_pos = click_pos

	# If Sprite2D is centered, the local origin is at the center of the texture
	if parent is Sprite2D and parent.centered:
		tex_pos += texture.get_size() / 2.0

	# Safety check
	if tex_pos.x < 0 or tex_pos.y < 0 or tex_pos.x >= image.get_width() or tex_pos.y >= image.get_height():
		return false

	var alpha = image.get_pixelv(Vector2i(tex_pos)).a
	return alpha > 0.1


func start_dialogue(extra_game_states: Array = []) -> void:
	if dialogue_resource:
		# Use '_get_start_title()' which can be overridden by scripts extending this class
		var title = _get_start_title()
		DialogueService.start_dialogue(dialogue_resource, title, extra_game_states, portrait_texture, portrait_scene)


	else:
		var msg = "DialogueTrigger [%s]: No dialogue resource assigned." % name
		push_warning(msg)
		print(msg)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not dialogue_resource:
		warnings.append("No dialogue resource assigned.")
	return warnings

# Virtual method: Override this in attached scripts to add conditional logic
# e.g. return "start_quest_2" if has_flag("quest_1_complete")
func _get_start_title() -> String:
	# 1. Check variants in order
	for variant in variants:
		if variant.are_conditions_met():
			return variant.start_title

	# 2. Fallback to default
	return dialogue_start

# --- Helper Methods for Cleaner Logic in Child Scripts ---

## Checks if a flag is true in the ProgressionManager
func has_flag(flag: String) -> bool:
	return ProgressionManager.get_flag(flag)

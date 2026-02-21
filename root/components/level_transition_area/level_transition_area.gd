@tool
extends Area2D
class_name LevelTransitionArea

@export var true_flags: Array[String]
@export_file("*.tscn") var scene_path: String

@export_group("Interaction Settings")
## If enabled and no CollisionShape2D exists, it will be created based on parent Sprite/Texture size + 12px.
@export var auto_setup: bool = true:
	set(value):
		auto_setup = value
		if auto_setup: _perform_auto_setup()

const MARGIN: float = 12.0

func _ready() -> void:
	# Ensure the area is pickable
	input_pickable = true

	if auto_setup:
		_perform_auto_setup()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if Engine.is_editor_hint(): return

	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && event.pressed:
			for flag in true_flags:
				if !ProgressionManager.get_flag(flag):
					return
			ScreenTransition.transition_to_scene(scene_path)

func _perform_auto_setup() -> void:
	# 1. Handle mouse filter for Control parents
	var parent = get_parent()
	if not parent: return

	if parent is Control and parent.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		parent.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 2. Check if we already have a collision child
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return

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
		var shape_node = CollisionShape2D.new()
		shape_node.name = "AutoCollisionShape"
		var rect_shape = RectangleShape2D.new()
		# Add 24px total to size as requested (+12px margin on each side)
		rect_shape.size = size + Vector2(24, 24)
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
			print("LevelTransitionArea: Auto-created collision shape for ", parent.name)

extends Control

func _ready() -> void:
	# Small delay to ensure all eye nodes are ready and animations can start
	await get_tree().process_frame

	for child in get_children():
		_setup_eyes_recursively(child)

func _setup_eyes_recursively(node: Node) -> void:
	if node is MonsterEye:
		# FIX MASKING AT RUNTIME
		# Godot 4 nested clip_children can fail if using CLIP_CHILDREN_AND_DRAW.
		# CLIP_CHILDREN_ONLY (1) is more robust for sub-masking.
		var mask = node.get_node_or_null("Mask")
		if mask is Polygon2D:
			mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
			mask.color = Color(1, 1, 1, 1) # Opaque color provides the mask alpha
			mask.self_modulate = Color(1, 1, 1, 1)

		node.can_blink = true
		node.show_debug_radius = false
		node.open_eye()
		node.enable_tracking()

	for child in node.get_children():
		_setup_eyes_recursively(child)

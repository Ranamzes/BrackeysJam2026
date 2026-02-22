extends Control

func _ready() -> void:
	# Small delay to ensure all eye nodes are ready and animations can start
	await get_tree().process_frame

	for child in get_children():
		if child is MonsterEye:
			# FIX MASKING AT RUNTIME
			# Godot 4 nested clip_children can fail if using CLIP_CHILDREN_AND_DRAW.
			# CLIP_CHILDREN_ONLY (1) is more robust for sub-masking.
			var mask = child.get_node_or_null("Mask")
			if mask is Polygon2D:
				mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
				mask.color = Color(1, 1, 1, 1) # Opaque color provides the mask alpha
				# self_modulate doesn't matter for CLIP_ONLY, but let's keep it clean
				mask.self_modulate = Color(1, 1, 1, 1)

			child.can_blink = true
			child.show_debug_radius = false
			child.open_eye()
			child.enable_tracking()

extends Control

func _ready() -> void:
	# Small delay to ensure all eye nodes are ready and animations can start
	await get_tree().process_frame

	for child in get_children():
		if child is MonsterEye:
			# Fix potential white display issue by ensuring the Mask polygon is only clipping
			# and its own color doesn't interfere.
			var mask = child.get_node_or_null("Mask")
			if mask is Polygon2D:
				mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
				mask.color = Color(0, 0, 0, 0) # Make polygon itself transparent

			child.show_debug_radius = false
			child.open_eye()
			child.enable_tracking()
		elif child.has_method("open_eye"):
			child.open_eye()

		if child.has_method("enable_tracking"):
			child.enable_tracking()

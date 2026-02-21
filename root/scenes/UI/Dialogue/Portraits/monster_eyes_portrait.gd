extends Control

func _ready() -> void:
	for child in get_children():
		if child is MonsterEye:
			child.open_eye()
			child.enable_tracking()
		elif child.has_method("open_eye"):
			child.open_eye()

		# If it has tracking capability but isn't explicitly open_eye
		if child.has_method("enable_tracking"):
			child.enable_tracking()

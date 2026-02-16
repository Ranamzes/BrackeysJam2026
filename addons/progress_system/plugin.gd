@tool
extends EditorPlugin

const ProgressDock: PackedScene = preload("res://addons/progress_system/progress_dock.tscn")
var dock: Control

func _enter_tree() -> void:
	dock = ProgressDock.instantiate()
	if dock.has_method("set_undo_redo"):
		dock.set_undo_redo(get_undo_redo())

	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree() -> void:
	if is_instance_valid(dock):
		remove_control_from_docks(dock)
		dock.queue_free()

func _get_plugin_name() -> String:
	return "Progress"

# Ensure the list is refreshed when the dock becomes visible
func _make_visible(visible: bool) -> void:
	if visible and is_instance_valid(dock) and dock.has_method("refresh_list"):
		dock.refresh_list()

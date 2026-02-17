@tool
extends VBoxContainer

const PROGRESSION_DATA_TRES = "res://root/autoload/progression_manager/progression_data.tres"

@onready var flag_list = %FlagList
@onready var search_edit = %Search
@onready var new_flag_name_edit = %NewFlagName
@onready var add_button = %AddButton
@onready var refresh_button = %RefreshButton

var undo_redo: EditorUndoRedoManager

func _ready():
	if not Engine.is_editor_hint():
		return

	refresh_button.icon = get_theme_icon("Reload", "EditorIcons")
	refresh_button.pressed.connect(refresh_list)
	add_button.pressed.connect(_on_add_button_pressed)
	search_edit.text_changed.connect(_on_search_changed)
	new_flag_name_edit.text_submitted.connect(func(_text): _on_add_button_pressed())

	call_deferred("refresh_list")

func set_undo_redo(ur: EditorUndoRedoManager):
	undo_redo = ur

func refresh_list():
	if not is_inside_tree(): return

	for child in flag_list.get_children():
		child.queue_free()

	var state_table = _get_state_table()
	var filter = search_edit.text.to_lower()

	var keys = state_table.keys()
	keys.sort()

	for key in keys:
		if filter != "" and not key.to_lower().contains(filter):
			continue
		_add_flag_row(key, state_table[key])

func _add_flag_row(key: String, value: bool):
	var row = HBoxContainer.new()
	flag_list.add_child(row)

	var checkbox = CheckBox.new()
	checkbox.button_pressed = value
	checkbox.toggled.connect(func(new_val): _on_flag_toggled(key, new_val))
	row.add_child(checkbox)

	var label = Label.new()
	label.text = key
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.clip_text = true
	label.tooltip_text = key
	row.add_child(label)

	var copy_btn = Button.new()
	copy_btn.icon = get_theme_icon("ActionCopy", "EditorIcons")
	copy_btn.flat = true
	copy_btn.tooltip_text = "Copy flag key to clipboard"
	copy_btn.pressed.connect(func(): DisplayServer.clipboard_set(key))
	row.add_child(copy_btn)

	var delete_btn = Button.new()
	delete_btn.icon = get_theme_icon("Remove", "EditorIcons")
	delete_btn.flat = true
	delete_btn.tooltip_text = "Delete flag"
	delete_btn.pressed.connect(func(): _on_delete_flag(key))
	row.add_child(delete_btn)

func _get_state_table() -> Dictionary:
	# Priority 1: Currently edited scene root (if it's the ProgressionManager)
	var root = EditorInterface.get_edited_scene_root()
	if is_instance_valid(root) and root.get_script() and root.get_script().resource_path.contains("progression_manager.gd"):
		var data = root.get("progression_data")
		if data:
			return data.state_table.duplicate()

	# Priority 2: Load the resource file
	var path = PROGRESSION_DATA_TRES
	if not FileAccess.file_exists(path):
		return {}

	var res = load(path)
	if not res: return {}

	return res.state_table.duplicate()

func _apply_table_change(new_table: Dictionary):
	var root = EditorInterface.get_edited_scene_root()
	var target_resource = null

	if is_instance_valid(root) and root.get_script() and root.get_script().resource_path.contains("progression_manager.gd"):
		target_resource = root.get("progression_data")

	if not target_resource or not "state_table" in target_resource:
		target_resource = load(PROGRESSION_DATA_TRES)

	if not target_resource or not "state_table" in target_resource:
		var detail = "Resource is null" if not target_resource else "Missing state_table property"
		push_error("Could not find valid ProgressionData resource: %s" % detail)
		return

	# Safety check: if the new table is empty but the old one wasn't,
	# and this isn't a deliberate deletion of the last flag, something is wrong.
	var old_table = _get_state_table()
	if new_table.is_empty() and not old_table.is_empty():
		# This could happen if the list failed to load correctly.
		# We should probably warn or block it unless it's a known deletion.
		pass

	if undo_redo:
		undo_redo.create_action("Modify Progress Flags")
		undo_redo.add_do_property(target_resource, "state_table", new_table)
		undo_redo.add_undo_property(target_resource, "state_table", _get_state_table())
		undo_redo.add_do_method(self, "refresh_list")
		undo_redo.add_undo_method(self, "refresh_list")
		undo_redo.add_do_method(self, "_save_resource", target_resource)
		undo_redo.add_undo_method(self, "_save_resource", target_resource)
		undo_redo.commit_action()
	else:
		target_resource.state_table = new_table
		_save_resource(target_resource)
		refresh_list()

func _save_resource(res: Resource):
	ResourceSaver.save(res, PROGRESSION_DATA_TRES)
	EditorInterface.get_resource_filesystem().scan()

func _save_to_file(_new_table: Dictionary):
	# Obsolete but kept for compatibility if needed during transition
	pass

func _on_add_button_pressed():
	var new_name = new_flag_name_edit.text.strip_edges()
	if new_name == "": return

	var table = _get_state_table()
	if table.has(new_name): return

	table[new_name] = false
	_apply_table_change(table)
	new_flag_name_edit.clear()

func _on_flag_toggled(key: String, new_val: bool):
	var table = _get_state_table()
	if table.get(key) == new_val: return
	table[key] = new_val
	_apply_table_change(table)

func _on_delete_flag(key: String):
	var table = _get_state_table()
	if not table.has(key): return
	table.erase(key)
	_apply_table_change(table)

func _on_search_changed(_text: String):
	refresh_list()

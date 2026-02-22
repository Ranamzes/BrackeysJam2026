extends Node2D

var _loop_tweens: Array[Tween] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Navigation is now handled by flags in the HUD component
	# Check if level was already visited
	AudioService.play_music(preload("res://root/assets/music/clean.mp3"), &"Music", 1.0, -10)
	if not ProgressionManager.get_flag("level_1_visited"):
		# Wait one second then trigger dialogue
		get_tree().create_timer(1.0).timeout.connect(_on_entry_timeout)

	# Setup initial foam visibility
	var pipes_solved = ProgressionManager.get_flag("pipes_solved")
	var duck_picked = ProgressionManager.get_flag("duck_picker")

	if pipes_solved and not duck_picked:
		$pena.visible = true
		if ProgressionManager.get_flag("duck_surfaced"):
			_show_foam_static()
		else:
			_animate_shower_entrance()
	else:
		$pena.visible = false

	ProgressionManager.progression_data.flag_changed.connect(flags_changed)

func _on_entry_timeout() -> void:
	var lady_tv_trigger = $CharacterTv/DialogueClickable
	if lady_tv_trigger:
		lady_tv_trigger.start_dialogue()

func flags_changed(flag_name: String, _flag_value: bool) -> void:
	match flag_name:
		"quest_bottles_started":
			if _flag_value:
				$Hud.update_navigation()
		"soap_full_picked_up":
			GlobalData.player_inventory.remove_item(preload("res://root/assets/items/soap_empty.tres"))
			GlobalData.player_inventory.add_item(preload("res://root/assets/items/soap_full.tres"))
		"pipes_solved":
			if _flag_value and not ProgressionManager.get_flag("duck_picker"):
				if not ProgressionManager.get_flag("duck_surfaced"):
					_animate_shower_entrance()

func _show_foam_static() -> void:
	$pena.visible = true
	var foam_mask: Polygon2D = $pena/FoamMask
	foam_mask.modulate.a = 1.0

	var i := 0
	for child in foam_mask.get_children():
		if not child is Sprite2D or child.name == "Duck":
			continue
		if child.name == "Shower":
			child.modulate.a = 1.0
			continue

		child.modulate.a = 1.0
		_start_foam_sway(child, i)
		i += 1

	var duck: Sprite2D = $pena/FoamMask/Duck
	if duck:
		duck.modulate.a = 1.0
		_start_duck_idle(duck, duck.position, duck.rotation)

func _animate_shower_entrance() -> void:
	$pena.visible = true
	var shower: Sprite2D = $pena/FoamMask/Shower
	var foam_mask: Polygon2D = $pena/FoamMask

	# Initial state: everything hidden
	foam_mask.modulate.a = 1.0 # Mask must be visible for children to show
	for child in foam_mask.get_children():
		if child is Sprite2D:
			child.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(shower, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_callback(_animate_foam_appearance)

func _animate_foam_appearance() -> void:
	var foam_mask: Polygon2D = $pena/FoamMask

	var i := 0
	for child in foam_mask.get_children():
		if not child is Sprite2D or child.name == "Duck" or child.name == "Shower":
			continue

		var rest_pos: Vector2 = child.position
		var rise_offset := 60.0 + i * 8.0
		var delay := i * 0.1
		var rise_dur := 1.0 + i * 0.05

		child.position.y = rest_pos.y + rise_offset
		child.modulate.a = 0.0

		var rise_tween = create_tween()
		rise_tween.tween_interval(delay)
		rise_tween.parallel().tween_property(child, "modulate:a", 1.0, 0.4)
		rise_tween.parallel().tween_property(child, "position:y", rest_pos.y, rise_dur) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		_start_foam_sway(child, i, delay + rise_dur * 0.6)
		i += 1

	get_tree().create_timer(0.8).timeout.connect(_animate_duck_surface)

func _animate_duck_surface() -> void:
	var duck: Sprite2D = $pena/FoamMask/Duck
	if not duck: return

	var rest_pos := duck.position
	var rest_rot := duck.rotation

	duck.position.y = rest_pos.y + 40.0
	duck.modulate.a = 0.0

	var duck_tween = create_tween()
	duck_tween.tween_property(duck, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	duck_tween.parallel().tween_property(duck, "position:y", rest_pos.y, 1.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	duck_tween.parallel().tween_property(duck, "rotation", rest_rot + 0.25, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	duck_tween.tween_property(duck, "rotation", rest_rot - 0.2, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	duck_tween.tween_property(duck, "rotation", rest_rot, 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	duck_tween.tween_callback(func(): ProgressionManager.set_flag("duck_surfaced", true))
	_start_duck_idle(duck, rest_pos, rest_rot, 2.0)

func _exit_tree() -> void:
	for t in _loop_tweens:
		if is_instance_valid(t):
			t.kill()
	_loop_tweens.clear()

func _start_foam_sway(child: Sprite2D, i: int, start_delay: float = 0.0) -> void:
	var rest_x := child.position.x
	var sway_amp := 6.0 + fmod(float(i), 3.0) * 3.0
	var sway_dur := 1.8 + fmod(float(i), 4.0) * 0.3
	var sway_dir := 1.0 if i % 2 == 0 else -1.0

	var actual_start = func():
		if not is_instance_valid(child):
			return
		var loop_tween = create_tween().set_loops()
		loop_tween.tween_property(child, "position:x", rest_x + sway_amp * sway_dir, sway_dur) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		loop_tween.tween_property(child, "position:x", rest_x - sway_amp * sway_dir, sway_dur) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_loop_tweens.append(loop_tween)

	if start_delay > 0:
		get_tree().create_timer(start_delay).timeout.connect(actual_start)
	else:
		actual_start.call()

func _start_duck_idle(duck: Sprite2D, rest_pos: Vector2, rest_rot: float, start_delay: float = 0.0) -> void:
	var actual_start = func():
		if not is_instance_valid(duck):
			return
		var bob_tween = create_tween().set_loops()
		bob_tween.tween_property(duck, "position:y", rest_pos.y - 4.0, 1.2) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		bob_tween.tween_property(duck, "position:y", rest_pos.y, 1.2) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_loop_tweens.append(bob_tween)

		var rot_tween = create_tween().set_loops()
		rot_tween.tween_property(duck, "rotation", rest_rot + 0.08, 1.5) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		rot_tween.tween_property(duck, "rotation", rest_rot - 0.08, 1.5) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_loop_tweens.append(rot_tween)

	if start_delay > 0:
		get_tree().create_timer(start_delay).timeout.connect(actual_start)
	else:
		actual_start.call()

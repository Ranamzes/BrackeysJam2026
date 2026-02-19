extends CanvasLayer


signal transition_halfway
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var monitor_overlay: VBoxContainer = $MonitorOverlay

func _ready() -> void:
	print("[Debug] ScreenTransition Autoload is READY")
	# Ensure monitor overlay is hidden at start
	monitor_overlay.visible = false

func _input(event: InputEvent) -> void:
	# Check both InputMap and raw F2 for maximum reliability
	if event.is_action_pressed(&"toggle_debug") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_F2):
		monitor_overlay.visible = !monitor_overlay.visible
		print("[Debug] Toggle Overlay visibility: ", monitor_overlay.visible)
		# Consume the event so it doesn't trigger other things
		get_viewport().set_input_as_handled()

func transition():
	animation_player.play("transition")
	await animation_player.animation_finished
	transition_halfway.emit()
	animation_player.play_backwards("transition")

func transition_to_scene(new_scene_path: String):
	# Start loading immediately in parallel with the animation
	var error = ResourceLoader.load_threaded_request(new_scene_path)
	if error != OK:
		printerr("[Error] Failed to start threaded load for: ", new_scene_path)
		# Fallback: still show animation and then try to change scene normally (or fail)
		animation_player.play("transition")
		await animation_player.animation_finished
		get_tree().change_scene_to_file(new_scene_path)
		animation_player.play_backwards("transition")
		return

	# Start the transition animation
	animation_player.play("transition")

	# Poll for completion while allowing the animation to run
	var scene_loaded = false
	var new_scene_packed: PackedScene = null

	while not scene_loaded:
		var status = ResourceLoader.load_threaded_get_status(new_scene_path)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				new_scene_packed = ResourceLoader.load_threaded_get(new_scene_path)
				scene_loaded = true
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				printerr("[Error] Threaded load failed for: ", new_scene_path)
				# Fallback if possible or stop
				animation_player.play_backwards("transition")
				return

		if not scene_loaded:
			await get_tree().process_frame

	# Ensure animation has finished "darkening" the screen before switching
	if animation_player.is_playing() and animation_player.current_animation == "transition":
		await animation_player.animation_finished

	# Switch the scene
	get_tree().change_scene_to_packed(new_scene_packed)

	# Emit signal and fade out
	transition_halfway.emit()
	animation_player.play_backwards("transition")

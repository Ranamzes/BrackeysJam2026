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
	animation_player.play("transition")
	await animation_player.animation_finished

	# Start asynchronous loading
	var error = ResourceLoader.load_threaded_request(new_scene_path)
	if error != OK:
		printerr("[Error] Failed to start threaded load for: ", new_scene_path)
		animation_player.play_backwards("transition")
		return

	# Poll for completion
	while true:
		var status = ResourceLoader.load_threaded_get_status(new_scene_path)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var new_scene = ResourceLoader.load_threaded_get(new_scene_path)
				get_tree().change_scene_to_packed(new_scene)
				break
			ResourceLoader.THREAD_LOAD_FAILED:
				printerr("[Error] Threaded load failed for: ", new_scene_path)
				break
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				printerr("[Error] Threaded load invalid resource: ", new_scene_path)
				break
		# Wait for a frame before checking again
		await get_tree().process_frame

	transition_halfway.emit()
	animation_player.play_backwards("transition")

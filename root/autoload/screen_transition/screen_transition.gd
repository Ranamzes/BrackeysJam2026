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
	get_tree().change_scene_to_file(new_scene_path)
	animation_player.play_backwards("transition")

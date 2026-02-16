extends Node2D


@onready var test_rect: ColorRect = %TestRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ProgressionManager.get_flag("button_on_right_screen_clicked"):
		test_rect.color = Color.RED


	# Connect gui_input signal for reliable click detection on the control
	test_rect.gui_input.connect(_on_test_rect_gui_input)

func _on_test_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Clicked TestRect, starting dialogue")
		var dialogue_ui = load("res://root/scenes/UI/Dialogue/DialogueUI.tscn").instantiate()
		add_child(dialogue_ui)

		var title = "start"
		if ProgressionManager.get_flag("button_on_right_screen_clicked"):
			title = "button_clicked"

		dialogue_ui.start(load("res://root/resources/dialogue/test.dialogue"), title)

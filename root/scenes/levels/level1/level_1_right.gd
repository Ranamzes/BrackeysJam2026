extends Node2D

@onready var test_button:SoundedButton = %TestButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_button.pressed.connect(on_test_button_pressed)
	if ProgressionManager.get_flag("button_on_right_screen_clicked"):
		test_button.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_test_button_pressed() -> void:
	ProgressionManager.set_flag("button_on_right_screen_clicked",true)
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	test_button.visible = false;
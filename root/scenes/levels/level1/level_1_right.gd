extends Node2D

@onready var test_button:SoundedButton = %TestButton

@onready var jars: Sprite2D = %Jars
@onready var jars_solved: Sprite2D = %JarsSolved
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_button.pressed.connect(on_test_button_pressed)
	if ProgressionManager.get_flag("button_on_right_screen_clicked"):
		test_button.visible = false
	if ProgressionManager.get_flag("bottles_solved"):
		jars.visible = false
		jars_solved.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func on_test_button_pressed() -> void:
	ProgressionManager.set_flag("button_on_right_screen_clicked",true)
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	test_button.visible = false;

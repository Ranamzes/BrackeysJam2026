extends CanvasLayer

@export_file("*.tscn") var left_scene: String
@export_file("*.tscn") var right_scene: String
@export_file("*.tscn") var top_scene: String
@export_file("*.tscn") var bottom_scene: String

@export var left_flag: String = ""
@export var right_flag: String = ""
@export var top_flag: String = ""
@export var bottom_flag: String = ""

@onready var left_button: NavButton = %NavButtonLeft
@onready var right_button: NavButton = %NavButtonRight
@onready var top_button: NavButton = %NavButtonTop
@onready var bottom_button: NavButton = %NavButtonBottom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_navigation()


func update_navigation() -> void:
	_setup_nav_button(left_button, left_scene, left_flag, "left")
	_setup_nav_button(right_button, right_scene, right_flag, "right")
	_setup_nav_button(top_button, top_scene, top_flag, "top")
	_setup_nav_button(bottom_button, bottom_scene, bottom_flag, "bottom")


func _setup_nav_button(button: NavButton, scene_path: String, flag: String, direction: String) -> void:
	if scene_path == "":
		button.visible = false
		return

	var should_be_visible = true
	if flag != "":
		should_be_visible = ProgressionManager.get_flag(flag)

	button.visible = should_be_visible
	if should_be_visible:
		if not button.pressed.is_connected(on_nav_button_pressed):
			button.pressed.connect(on_nav_button_pressed.bind(direction))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_nav_button_pressed(direction: String) -> void:
	var new_scene_path: String
	match direction:
		"left":
			new_scene_path = left_scene
		"right":
			new_scene_path = right_scene
		"top":
			new_scene_path = top_scene
		"bottom":
			new_scene_path = bottom_scene
	if new_scene_path == "":
		return
	ScreenTransition.transition_to_scene(new_scene_path)

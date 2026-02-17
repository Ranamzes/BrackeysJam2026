extends CanvasLayer

@export_file("*.tscn") var left_scene: String
@export_file("*.tscn") var right_scene: String
@export_file("*.tscn") var top_scene: String
@export_file("*.tscn") var bottom_scene: String
@onready var left_button: NavButton = %NavButtonLeft
@onready var right_button: NavButton = %NavButtonRight
@onready var top_button: NavButton = %NavButtonTop
@onready var bottom_button: NavButton = %NavButtonBottom
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if left_scene != "":
		left_button.visible = true
		left_button.pressed.connect(on_nav_button_pressed.bind("left"))
	if right_scene != "":
		right_button.visible = true
		right_button.pressed.connect(on_nav_button_pressed.bind("right"))
	if top_scene != "":
		top_button.visible = true
		top_button.pressed.connect(on_nav_button_pressed.bind("top"))
	if bottom_scene != "":
		bottom_button.visible = true
		bottom_button.pressed.connect(on_nav_button_pressed.bind("bottom"))


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

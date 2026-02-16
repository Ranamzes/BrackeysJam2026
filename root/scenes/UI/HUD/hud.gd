extends CanvasLayer

@export var left_scene:PackedScene
@export var right_scene:PackedScene
@export var top_scene:PackedScene
@export var bottom_scene:PackedScene
@onready var left_button:NavButton = %NavButtonLeft
@onready var right_button:NavButton = %NavButtonRight
@onready var top_button:NavButton = %NavButtonTop
@onready var bottom_button:NavButton = %NavButtonBottom
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if left_scene != null:
		left_button.visible = true
		left_button.pressed.connect(on_nav_button_pressed.bind("left"))
	if right_scene != null:
		right_button.visible = true
		right_button.pressed.connect(on_nav_button_pressed.bind("right"))
	if top_scene != null:
		top_button.visible = true
		top_button.pressed.connect(on_nav_button_pressed.bind("top"))
	if bottom_scene != null:
		bottom_button.visible = true
		bottom_button.pressed.connect(on_nav_button_pressed.bind("bottom"))
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_nav_button_pressed(direction: String) -> void:
	var new_scene:PackedScene
	match direction:
		"left":
			new_scene = left_scene
		"right":
			new_scene = right_scene
		"top":
			new_scene = top_scene
		"bottom":
			new_scene = bottom_scene
	if new_scene == null:
		return
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_packed(new_scene)	
				

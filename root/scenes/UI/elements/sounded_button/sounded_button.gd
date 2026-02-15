extends TextureButton

class_name SoundedButton
@export var text : String = "Placeholder";
@onready var label: Label = %Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = text
	pressed.connect(on_pressed)



func on_pressed():
	$StreamPlayerComponent.play_random()

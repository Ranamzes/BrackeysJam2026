extends Node2D


@onready var jars: Sprite2D = %Jars
@onready var jars_solved: Sprite2D = %JarsSolved
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ProgressionManager.get_flag("bottles_solved"):
		jars.visible = false
		jars_solved.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

extends Node2D

@onready var buttonRight: Sprite2D = %ButtonRight
@onready var pipesPuzzle:PipesPuzzle = %PipesPuzzle
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pipesPuzzle.puzzle_solved.connect(on_solved)


func on_solved() -> void:
	buttonRight.visible = true

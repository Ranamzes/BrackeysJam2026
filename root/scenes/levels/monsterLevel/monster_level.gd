extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioService.play_music(preload("res://root/assets/music/calming.mp3"), &"Music",1.0,-10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

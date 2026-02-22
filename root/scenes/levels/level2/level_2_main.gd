extends Node2D

@onready var tele1:Sprite2D = $DreamcoreStarTelescoope1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(ProgressionManager.get_flag("puzzle_colors_solved")):
		tele1.queue_free()
	AudioService.play_music(preload("res://root/assets/music/dream.mp3"), &"Music",1.0,-10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

@onready var toothbrush_sprite:Sprite2D = %Toothbrush
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(ProgressionManager.get_flag("toothbrush_picked_up")):
		toothbrush_sprite.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

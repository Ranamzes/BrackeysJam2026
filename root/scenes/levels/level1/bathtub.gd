extends Node2D
@onready var anim_player:AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ProgressionManager.get_flag("duck_placed"):
		anim_player.play("solution")
	else:
		anim_player.play("RESET")	
	ProgressionManager.progression_data.changed.connect(flags_changed)

func flags_changed(flag_name : String, flag_value : bool) -> void:
	if flag_name ==	"duck_placed" and flag_value:
		anim_player.play("solution")


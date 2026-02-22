extends Node2D

@onready var tele1: Sprite2D = $DreamcoreStarTelescoope1
@onready var hud: HUD = $Hud

const STARHEAD_DIALOGUE = preload("res://root/resources/dialogue/starhead.dialogue")
const STARHEAD_PORTRAIT = preload("res://root/scenes/UI/Dialogue/Portraits/StarheadPortrait.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (ProgressionManager.get_flag("puzzle_colors_solved")):
		tele1.queue_free()

	if not ProgressionManager.get_flag("level_2_visited"):
		_auto_trigger_dialogue()

func _auto_trigger_dialogue() -> void:
	await get_tree().create_timer(0.5).timeout
	DialogueService.start_dialogue(STARHEAD_DIALOGUE, "start", [], null, STARHEAD_PORTRAIT)

	# After dialogue finished, update HUD
	DialogueService.current_dialogue_ui.finished.connect(func():
		hud.update_navigation()
	, CONNECT_ONE_SHOT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

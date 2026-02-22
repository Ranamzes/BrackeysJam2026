extends Polygon2D
## SteamVent – lightweight steam effect for browser builds.
## Preprocesses all CPUParticles2D children so steam appears
## "already alive" when the scene is entered.

@export var preprocess_seconds: float = 3.0

func _ready() -> void:
	var levers_solved: bool = ProgressionManager.get_flag("levers_solved")
	var steam_off: bool = ProgressionManager.get_flag("steam_off")

	if steam_off:
		visible = false
		return

	if levers_solved:
		for child in get_children():
			if child is CPUParticles2D:
				child.amount = 0
		return

	# Only preprocess if steam is still active
	for child in get_children():
		if child is CPUParticles2D:
			child.preprocess = preprocess_seconds

func _exit_tree() -> void:
	if ProgressionManager.get_flag("levers_solved"):
		ProgressionManager.set_flag("steam_off", true)

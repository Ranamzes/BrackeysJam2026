extends Polygon2D
## SteamVent – lightweight steam effect for browser builds.
## Preprocesses all CPUParticles2D children so steam appears
## "already alive" when the scene is entered.


func _ready() -> void:
	ProgressionManager.progression_data.flag_changed.connect(_on_flag_changed)
	_update_steam()

func _on_flag_changed(flag: String, _value: bool) -> void:
	if flag == "levers_solved" or flag == "steam_off":
		_update_steam()

func _update_steam() -> void:
	var levers_solved: bool = ProgressionManager.get_flag("levers_solved")
	var steam_off: bool = ProgressionManager.get_flag("steam_off")

	print("[SteamVent] LeversSolved: %s, SteamOff: %s" % [levers_solved, steam_off])

	# Scenario 1: Both true -> Hide entirely
	if levers_solved and steam_off:
		visible = false
		return

	# Scenario 2: Levers solved, but steam_off not yet set (first time solving)
	# Wait 0.5s before stopping particles
	if levers_solved and not steam_off:
		visible = true
		await get_tree().create_timer(0.2).timeout
		_set_emitting(false)
		return

	# Scenario 3: Normal operation (not solved yet)
	visible = true
	_set_emitting(true)

func _set_emitting(state: bool) -> void:
	for child in get_children():
		if child is CPUParticles2D:
			if child.emitting != state:
				child.emitting = state

func _exit_tree() -> void:
	if ProgressionManager.get_flag("levers_solved"):
		ProgressionManager.set_flag("steam_off", true)

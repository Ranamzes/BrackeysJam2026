extends Node2D

@export var	lock_rings: Array[LockRing]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for lock_ring in lock_rings:
		lock_ring.state_changed.connect(on_ring_state_changed)	
	print("test")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_ring_state_changed()->void:
	var is_solved:bool = true
	for lock_ring in lock_rings:
		if(not lock_ring.is_solved):
			is_solved = false
	if is_solved:
		for lock_ring in lock_rings:
			lock_ring.is_rotatable = false
		ProgressionManager.set_flag("telescope_solved",true)
		print("solved")
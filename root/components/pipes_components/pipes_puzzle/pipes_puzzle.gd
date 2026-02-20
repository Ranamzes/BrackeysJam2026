extends Node2D

class_name PipesPuzzle
signal puzzle_solved

@export var pipes: Array[PipeSegment]
@export var start_index: int = 20
@export var end_index: int = 29
@export var height: int = 6
@export var lenght: int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pipe in pipes:
		if pipe != null:
			pipe.state_updated.connect(check_solution)
	check_solution.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_row(index: int) -> int:
	@warning_ignore("integer_division")
	return index / 10

func get_column(index: int) -> int:
	return index % 10

func get_raw_index(row: int, column: int) -> int:
	return row * 10 + column

func check_solution():
	if check_next_pipe(start_index, -1):
		puzzle_solved.emit()
		ProgressionManager.set_flag("pipes_solved", true)
		for pipe in pipes:
			if pipe != null:
				pipe.is_rotatable = false

	for pipe in pipes:
		if pipe != null:
			pipe.update_power()
			pipe.is_powered = false


func check_next_pipe(pipe_index: int, incoming_index: int) -> bool:
	var is_solved:bool = false
	var current_cell: PipeSegment = pipes[pipe_index]
	if current_cell == null:
		return false
	if current_cell.is_powered:
		return false
	else: current_cell.is_powered = true
	if pipe_index == end_index:
		return true
	for direction in current_cell.get_directions():
		var next_index: int
		var next_row: int
		var next_column: int
	
		match direction:
			0:
				next_row = get_row(pipe_index) - 1
				if next_row < 0 or next_row >= height:
					continue
				next_column = get_column(pipe_index)
				if next_column < 0 or next_column >= lenght:
					continue
				next_index = get_raw_index(next_row, next_column)
				if incoming_index != next_index and pipes[next_index] != null and 2 in pipes[next_index].get_directions():
					if (check_next_pipe(next_index, pipe_index)):
						is_solved = true
			1:
				next_row = get_row(pipe_index)
				if next_row < 0 or next_row >= height:
					continue
				next_column = get_column(pipe_index) + 1
				if next_column < 0 or next_column >= lenght:
					continue
				next_index = get_raw_index(next_row, next_column)
				if incoming_index != next_index and pipes[next_index] != null and 3 in pipes[next_index].get_directions():
					if (check_next_pipe(next_index, pipe_index)):
						is_solved = true
			2:
				next_row = get_row(pipe_index) + 1

				if next_row < 0 or next_row >= height:
					continue
				next_column = get_column(pipe_index)
				if next_column < 0 or next_column >= lenght:
					continue
				next_index = get_raw_index(next_row, next_column)
				if incoming_index != next_index and pipes[next_index] != null and 0 in pipes[next_index].get_directions():
					if (check_next_pipe(next_index, pipe_index)):
						is_solved = true
			3:
				next_row = get_row(pipe_index)
				if next_row < 0 or next_row >= height:
					continue
				next_column = get_column(pipe_index) - 1
				if next_column < 0 or next_column >= lenght:
					continue
				next_index = get_raw_index(next_row, next_column)
				if incoming_index != next_index and pipes[next_index] != null and 1 in pipes[next_index].get_directions():
					if (check_next_pipe(next_index, pipe_index)):
						is_solved = true


	return is_solved

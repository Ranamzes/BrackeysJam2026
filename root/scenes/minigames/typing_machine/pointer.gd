extends CharacterBody2D

@export var movement_component:MovementComponent
@export var path_size:int = 700
@export var speed_multiplier: float = 5
var global_top_boundary:Vector2
var global_bottom_boundary:Vector2
var is_going_top = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_component.base_speed = movement_component.base_speed * speed_multiplier
	global_top_boundary = global_position
	global_bottom_boundary = global_position
	global_top_boundary.y = global_top_boundary.y - path_size/2.0
	global_bottom_boundary.y = global_bottom_boundary.y + path_size/2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_going_top:
		if global_position.y < global_top_boundary.y:
			is_going_top = false
	else:
		if  global_position.y > global_bottom_boundary.y:
			is_going_top = true
		
	if is_going_top:
		movement_component.accelerate_to_direction(Vector2.UP)
	else:
		movement_component.accelerate_to_direction(Vector2.DOWN)
	
	movement_component.move(self)
	
	print(global_position.y)
	print(global_top_boundary.y)
	print(global_position)

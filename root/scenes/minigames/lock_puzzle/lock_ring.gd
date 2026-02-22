extends Area2D

class_name LockRing
signal state_changed
@export var radius:int = 0
@export var offset:float = 15.0
@export var number_of_segments: int = 8
@export var current_segment: int = 0
@export var correct_segment: int = 0
@export var texture:Texture2D
@onready var collision: CollisionShape2D = %CollisionShape
@onready var sprite: Sprite2D = %Sprite2D
var mouseDragStartAngle:float = 0
var initialOrientation:float = 0
var is_rotating:bool = false
var angle_per_segment:float
var is_solved:bool = false
var is_rotatable:bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = texture
	collision.position.y = -radius
	sprite.position.y = -radius
	angle_per_segment = 360.0/number_of_segments
	rotation = angle_per_segment*current_segment+deg_to_rad(offset)
	is_solved = current_segment==correct_segment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_rotatable and is_rotating:
		var vector = get_global_mouse_position() - global_position
		var mouseDragCurrentAngle = vector.angle()
		rotation = (mouseDragCurrentAngle - mouseDragStartAngle) + initialOrientation
		
	
func _on_input_event(viewport: Node, event:InputEvent,shape_idx:int):
	if is_rotatable and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			if event.pressed:

				initialOrientation = rotation	
				mouseDragStartAngle = (get_global_mouse_position() - global_position).angle()
				is_rotating = true
				
func _input(event:InputEvent)->void:
	if is_rotatable and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			if not event.pressed and is_rotating:
				is_rotating = false
				current_segment = round((rotation_degrees) / angle_per_segment)
				current_segment = current_segment % 360 % number_of_segments
				if current_segment<0:
					current_segment = number_of_segments+current_segment
				rotation_degrees = current_segment * angle_per_segment + offset
				check_solution()


func check_solution()->void:
	print(current_segment)
	print(correct_segment)
	is_solved = current_segment==correct_segment
	state_changed.emit()

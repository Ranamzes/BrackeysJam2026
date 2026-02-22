extends CharacterBody2D

class_name Pointer
@export var movement_component:MovementComponent
@export var path_size:int = 700
@export var speed_multiplier: float = 5
@onready var area: Area2D = %Area2D
@onready var sprite:Sprite2D = $Sprite2D
@export var textures:Array[Texture2D]
var base_speed = 40
var current_speed
var global_top_boundary:Vector2
var global_bottom_boundary:Vector2
var is_going_top = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_speed = 7
	global_top_boundary = global_position
	global_bottom_boundary = global_position
	global_top_boundary.y = global_top_boundary.y - path_size/2.0
	global_bottom_boundary.y = global_bottom_boundary.y + path_size/2.0
	global_position.y =  global_position.y - path_size/4.0
	print(movement_component.base_speed)

	modulate.a = 0
	reveal_pointer()
	
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
	
func reveal_pointer() -> void:
	update_speed(current_speed)
	var tween = create_tween()
	tween.tween_property(self ,"modulate:a",255,0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	
func update_speed(speed_mult:int)->void:
	print(base_speed * speed_mult)
	movement_component.base_speed =base_speed * speed_mult

func hide_pointer(next_speed:int) -> void:
	current_speed = next_speed
	var tween = create_tween()
	tween.tween_property(self ,"modulate:a",0,0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func change_texture(index:int)->void:
	sprite.texture=textures[index]
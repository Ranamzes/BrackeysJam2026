extends Node



class_name MovementComponent

@export var base_speed: int = 40
@export var acceleration: float = 5

var max_speed:int 
var velocity = Vector2.ZERO

func _ready() -> void:
	max_speed = base_speed

func accelerate_to_player():
	var owner_node2d = owner as Node2D
	if owner_node2d == null:
		return
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var direction = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_to_direction(direction)

func accelerate_to_direction(direction: Vector2):
	var desired_velocit = direction * max_speed 
	velocity = velocity.lerp(desired_velocit,1 - exp(-acceleration * get_process_delta_time()))

func decelerate():
	accelerate_to_direction(Vector2.ZERO)


func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
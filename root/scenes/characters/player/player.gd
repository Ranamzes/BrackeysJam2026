extends CharacterBody2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals : Node2D = $Visuals
@onready var movement_component: MovementComponent = $MovementComponent


func _ready() -> void:
	pass



func _process(delta: float) -> void:
	var movement_vector = get_movement_vector();
	var direction = movement_vector.normalized();
	
	movement_component.accelerate_to_direction(direction)
	movement_component.move(self)

	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	
	var move_sign = sign(movement_vector.x)
	if move_sign !=0:
		visuals.scale = Vector2(move_sign,1)


func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("move_right")-Input.get_action_strength("move_left");
	var y_movement = Input.get_action_strength("move_down")-Input.get_action_strength("move_up");
	return Vector2(x_movement,y_movement);
	
extends Area2D


class_name PipeSegment
var is_powered: bool
var is_rotating: bool
signal state_updated

@export_range(0, 3) var state: int
@export_enum("straight", "tshape", "cross", "angle") var type: String = "straight"
@export var is_rotatable: bool = true
@export var straight_sprite_texture: Texture
@export var tshape_sprite_texture: Texture
@export var cross_sprite_texture: Texture
@export var angle_sprite_texture: Texture
@export var powered_straight_sprite_texture: Texture
@export var powered_tshape_sprite_texture: Texture
@export var powered_cross_sprite_texture: Texture
@export var powered_angle_sprite_texture: Texture
@onready var visuals: Node2D = %Visuals
@onready var sprite: Sprite2D = %Sprite2D

var rotation_queue: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match type:
		"straight":
			sprite.texture = straight_sprite_texture
		"tshape":
			sprite.texture = tshape_sprite_texture
		"cross":
			sprite.texture = cross_sprite_texture
		"angle":
			sprite.texture = angle_sprite_texture
	visuals.rotation = deg_to_rad(90 * state)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and is_rotatable:
			if event.button_index == MOUSE_BUTTON_LEFT:
				rotation_queue.append(1)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				rotation_queue.append(-1)

			if not is_rotating:
				_process_next_rotation()


func _process_next_rotation():
	if rotation_queue.is_empty():
		return

	var dir = rotation_queue.pop_front()
	state = (state + dir + 4) % 4

	var move_deg = dir * 90
	var target_deg = rad_to_deg(visuals.rotation) + move_deg

	$StreamPlayerComponent.play_random()
	var tween = create_tween()
	is_rotating = true
	tween.tween_property(visuals, "rotation", deg_to_rad(target_deg), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(rotation_step_finished)

func rotation_step_finished():
	is_rotating = false
	# Cleanup rotation variable and sync with state
	visuals.rotation = fmod(visuals.rotation, TAU)
	if visuals.rotation < 0: visuals.rotation += TAU
	visuals.rotation = deg_to_rad(90 * state)

	state_updated.emit()
	_process_next_rotation()

func get_directions() -> Array[int]:
	match type:
		"straight":
			return [(1 + state) % 4, (3 + state) % 4]
		"tshape":
			return [(0 + state) % 4, (1 + state) % 4, (2 + state) % 4]
		"cross":
			return [0, 1, 2, 3]
		"angle":
			return [(0 + state) % 4, (3 + state) % 4]
	return []

func update_power() -> void:
		if is_powered:
			match type:
				"straight":
					sprite.texture = powered_straight_sprite_texture
				"tshape":
					sprite.texture = powered_tshape_sprite_texture
				"cross":
					sprite.texture = powered_cross_sprite_texture
				"angle":
					sprite.texture = powered_angle_sprite_texture
		else:
			match type:
				"straight":
					sprite.texture = straight_sprite_texture
				"tshape":
					sprite.texture = tshape_sprite_texture
				"cross":
					sprite.texture = cross_sprite_texture
				"angle":
					sprite.texture = angle_sprite_texture

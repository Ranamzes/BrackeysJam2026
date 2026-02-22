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

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_rotating and is_rotatable:
			state = (state + 1) % 4
			rotate_pipe(90 * state)


func rotate_pipe(deg: float):
	$StreamPlayerComponent.play_random()
	if (deg == 0):
		deg = 360
	var tween = create_tween()
	is_rotating = true
	tween.tween_property($Visuals, "rotation", deg_to_rad(deg), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(roation_finished)

func roation_finished():
	if state == 0:
		visuals.rotation = 0
	is_rotating = false
	state_updated.emit()

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

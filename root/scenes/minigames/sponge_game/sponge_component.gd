@tool
class_name SpongeComponent
extends TextureButton

signal sponge_clicked(id: StringName)

@export_group("Data")
@export var id: StringName
@export var normal_texture: Texture2D:
	set(value):
		normal_texture = value
		_update_visuals()

@export_group("Physics")
@export var swing_force: float = 1.5
@export var spring_stiffness: float = 40.0
@export var damping: float = 0.92
@export var max_swing_angle: float = 0.3 # Radians (~17 degrees)

var _angular_velocity: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_SCALE

	_update_visuals()

	if not Engine.is_editor_hint():
		pressed.connect(_on_pressed)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if abs(rotation) > 0.001 or abs(_angular_velocity) > 0.001:
		# Spring force back to zero
		var accel = - rotation * spring_stiffness
		_angular_velocity += accel * delta
		# Apply damping
		_angular_velocity *= pow(damping, delta * 60.0)
		rotation += _angular_velocity * delta

		# Limit the swing angle
		rotation = clamp(rotation, -max_swing_angle, max_swing_angle)
		if abs(rotation) >= max_swing_angle:
			_angular_velocity = 0.0 # Stop velocity on hit limit
	else:
		rotation = 0.0
		_angular_velocity = 0.0

func _update_visuals() -> void:
	if normal_texture:
		texture_normal = normal_texture

func _on_pressed() -> void:
	sponge_clicked.emit(id)

	# Add 'push' to the swing
	var push_direction = 1.0 if randf() > 0.5 else -1.0
	_angular_velocity += swing_force * push_direction

	if animation_player:
		animation_player.play(&"squish")

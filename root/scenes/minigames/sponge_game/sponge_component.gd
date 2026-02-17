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
var _is_idle: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_SCALE

	_update_visuals()

	if not Engine.is_editor_hint():
		pressed.connect(_on_pressed)
		set_physics_process(false) # Start idle

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Spring force back to zero
	var accel = - rotation * spring_stiffness
	_angular_velocity += accel * delta

	# Optimized damping (linear approximation for small delta)
	# Original: _angular_velocity *= pow(damping, delta * 60.0)
	# Linear version:
	_angular_velocity *= (1.0 - (1.0 - damping) * delta * 60.0)

	rotation += _angular_velocity * delta

	# Limit the swing angle
	if abs(rotation) >= max_swing_angle:
		rotation = clamp(rotation, -max_swing_angle, max_swing_angle)
		_angular_velocity = 0.0

	# Sleep mechanism: stop processing if movement is negligible
	if abs(rotation) < 0.01 and abs(_angular_velocity) < 0.02:
		rotation = 0.0
		_angular_velocity = 0.0
		_is_idle = true
		set_physics_process(false)

func _update_visuals() -> void:
	if normal_texture:
		texture_normal = normal_texture

func _on_pressed() -> void:
	sponge_clicked.emit(id)

	# Calculate physics based on click position
	var mouse_pos = get_local_mouse_position()

	# Direction: clicking left of pivot pushes it right, clicking right pushes it left
	# Note: pivot_offset is in local coordinates
	var offset_x = mouse_pos.x - pivot_offset.x
	var push_direction = -1.0 if offset_x > 0 else 1.0

	# Force: the further from the pivot (usually down), the more leverage
	# We normalize the distance relative to the control size
	var leverage = (mouse_pos.y - pivot_offset.y) / size.y
	leverage = clamp(leverage, 0.2, 1.5) # Minimum push even if clicked high up

	_angular_velocity += swing_force * push_direction * leverage

	# Wake up physics
	if _is_idle:
		_is_idle = false
		set_physics_process(true)

	_play_dynamic_squish(leverage)

func _play_dynamic_squish(intensity: float) -> void:
	# intensity is 0.2 to 1.5.
	# We'll make it more aggressive.
	var max_leverage := 1.5
	var max_squish_factor := 0.45 # Much stronger squish

	var current_squish = (intensity / max_leverage) * max_squish_factor
	var target_scale_x = 1.0 - current_squish
	var target_scale_y = 1.0 + (current_squish * 0.5) # Stretch Y a bit to preserve volume feel

	# Procedural squish animation using Tween
	var tween = create_tween()

	# Squish in (Parallel)
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale:x", target_scale_x, 0.07)
	tween.tween_property(self, "scale:y", target_scale_y, 0.07)

	# Bounce back (Chained + Parallel)
	tween.set_parallel(false)
	tween.tween_interval(0.0)
	tween.set_parallel(true)
	# Use TRANS_BACK for a softer, more controlled spring-back than ELASTIC
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale:x", 1.0, 0.25)
	tween.tween_property(self, "scale:y", 1.0, 0.25)

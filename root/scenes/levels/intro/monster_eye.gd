@tool
class_name MonsterEye
extends Node2D

@export_group("Textures")
@export var base_texture: Texture2D:
	set(val):
		base_texture = val
		_update_texture("Mask/Base", val)
@export var iris_texture: Texture2D:
	set(val):
		iris_texture = val
		_update_texture("Mask/Iris", val)
@export var shadow_texture: Texture2D:
	set(val):
		shadow_texture = val
		_update_texture("Mask/Shadow", val)
@export var light_texture: Texture2D:
	set(val):
		light_texture = val
		_update_texture("Mask/Light", val)
@export var upper_lid_texture: Texture2D:
	set(val):
		upper_lid_texture = val
		_update_texture("UpperLid", val)
@export var lower_lid_texture: Texture2D:
	set(val):
		lower_lid_texture = val
		_update_texture("LowerLid", val)

@export_group("Settings")
@export var blink_min: float = 2.0
@export var blink_max: float = 8.0
@export var move_radius_x: float = 15.0:
	set(val):
		move_radius_x = val
		queue_redraw()
@export var move_radius_y: float = 15.0:
	set(val):
		move_radius_y = val
		queue_redraw()
@export var move_rotation: float = 0.0:
	set(val):
		move_rotation = val
		queue_redraw()
@export var iris_center_offset: Vector2 = Vector2.ZERO:
	set(val):
		iris_center_offset = val
		_update_iris_position_in_editor()
		queue_redraw()
@export var show_debug_radius: bool = false:
	set(val):
		show_debug_radius = val
		queue_redraw()

@export_group("Light Jitter")
@export var light_jitter_intensity: float = 0.5
@export var light_jitter_speed: float = 40.0
@export var light_follow_strength: Vector2 = Vector2(0.1, 0.1)

@onready var iris_sprite: Sprite2D = find_child("Iris", true, false)
@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var light_sprite: Sprite2D = find_child("Light", true, false)

var can_track: bool = false
var original_iris_pos: Vector2 = Vector2.ZERO
var blink_timer: float = 0.0
var jitter_time: float = 0.0
var _debug_rid: RID
var original_light_pos: Vector2 = Vector2.ZERO

signal opened()

func _ready() -> void:
	_update_all_textures()

	if iris_sprite:
		original_iris_pos = iris_sprite.position
	if light_sprite:
		original_light_pos = light_sprite.position

	if Engine.is_editor_hint():
		if anim_player and anim_player.has_animation("open"):
			anim_player.play("open")
			anim_player.advance(100.0)
			anim_player.stop()
		# Cleanup leftover overlay nodes from broken previous versions
		var old_overlay = get_node_or_null("_DebugOverlay")
		if old_overlay:
			old_overlay.queue_free()
		return

	blink_timer = randf_range(blink_min, blink_max)

func _update_iris_position_in_editor() -> void:
	if Engine.is_editor_hint() and iris_sprite:
		_ensure_original_pos()
		iris_sprite.position = original_iris_pos + iris_center_offset

func _ensure_original_pos() -> void:
	if not iris_sprite:
		iris_sprite = find_child("Iris", true, false)
	if iris_sprite and original_iris_pos == Vector2.ZERO:
		original_iris_pos = iris_sprite.position

func _exit_tree() -> void:
	if _debug_rid.is_valid():
		RenderingServer.free_rid(_debug_rid)
		_debug_rid = RID()

func _update_debug_overlay() -> void:
	# Create the RenderingServer canvas item once
	if not _debug_rid.is_valid():
		_debug_rid = RenderingServer.canvas_item_create()
		# Parent to canvas of the viewport, NOT the node so it draws on top
		RenderingServer.canvas_item_set_parent(_debug_rid, get_canvas_item())
		# Use absolute z_index (not relative to parent) at maximum value
		RenderingServer.canvas_item_set_z_as_relative_to_parent(_debug_rid, false)
		RenderingServer.canvas_item_set_z_index(_debug_rid, 4096)

	# Clear previous frame drawing
	RenderingServer.canvas_item_clear(_debug_rid)

	if not show_debug_radius:
		return

	_ensure_original_pos()
	if not iris_sprite:
		return

	var center = original_iris_pos + iris_center_offset
	var rot_rad = deg_to_rad(move_rotation)

	# Draw ellipse outline
	var points = PackedVector2Array()
	var sides: int = 64
	for i in range(sides + 1):
		var angle = float(i) * TAU / float(sides)
		var p = Vector2(cos(angle) * move_radius_x, sin(angle) * move_radius_y)
		points.push_back(center + p.rotated(rot_rad))
	RenderingServer.canvas_item_add_polyline(_debug_rid, points, PackedColorArray([Color.YELLOW]), 2.0)

	# Draw crosshair along the rotation axes
	var cs: float = 15.0
	var h_dir = Vector2(cs, 0).rotated(rot_rad)
	var v_dir = Vector2(0, cs).rotated(rot_rad)
	RenderingServer.canvas_item_add_line(_debug_rid, center - h_dir, center + h_dir, Color.YELLOW, 1.0)
	RenderingServer.canvas_item_add_line(_debug_rid, center - v_dir, center + v_dir, Color.YELLOW, 1.0)

	# Draw center dot
	RenderingServer.canvas_item_add_circle(_debug_rid, center, 3.0, Color.YELLOW)

func _update_all_textures() -> void:
	_update_texture("Mask/Base", base_texture)
	_update_texture("Mask/Iris", iris_texture)
	_update_texture("Mask/Shadow", shadow_texture)
	_update_texture("Mask/Light", light_texture)
	_update_texture("UpperLid", upper_lid_texture)
	_update_texture("LowerLid", lower_lid_texture)

func _update_texture(node_path: String, tex: Texture2D) -> void:
	# Try direct path first for performance
	var node = get_node_or_null(node_path)

	# If not found (e.g. if reparented in editor), search recursively
	if not node:
		var node_name = node_path.split("/")[-1]
		node = find_child(node_name, true, false)

	if node:
		node.texture = tex
	elif not is_inside_tree():
		# If we're setting properties before nodes are created,
		# we rely on _ready() to apply them later.
		pass

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_debug_overlay()
		return

	# Light jitter (always active when eye is visible)
	if light_sprite and light_jitter_intensity > 0:
		jitter_time += delta * light_jitter_speed
		var jitter = Vector2(
			sin(jitter_time) * cos(jitter_time * 0.7),
			cos(jitter_time * 0.8) * sin(jitter_time * 0.5)
		) * light_jitter_intensity
		light_sprite.offset = jitter

	if can_track:
		# Blinking logic
		blink_timer -= delta
		if blink_timer <= 0:
			if anim_player.has_animation("blink"):
				anim_player.play("blink")
			blink_timer = randf_range(blink_min, blink_max)

		# Since the intro is inside a CanvasLayer without a camera,
		# get_viewport().get_mouse_position() works perfectly for screen-space tracking.
		var mouse_pos = get_viewport().get_mouse_position()
		var local_mouse = to_local(mouse_pos)

		# Elliptical clamping logic
		var center = original_iris_pos + iris_center_offset
		var rel_mouse = local_mouse - center
		var rot_rad = deg_to_rad(move_rotation)
		var rotated_mouse = rel_mouse.rotated(-rot_rad)

		# Map to unit circle
		var unit_space_mouse = Vector2(
			rotated_mouse.x / max(0.01, move_radius_x),
			rotated_mouse.y / max(0.01, move_radius_y)
		)

		if unit_space_mouse.length() > 1.0:
			unit_space_mouse = unit_space_mouse.normalized()

		# Back to local space
		var clamped_rel = Vector2(
			unit_space_mouse.x * move_radius_x,
			unit_space_mouse.y * move_radius_y
		).rotated(rot_rad)

		# Smoothly interpolate iris pos
		iris_sprite.position = iris_sprite.position.lerp(center + clamped_rel, 5.0 * delta)

		# Move light slightly to follow the iris
		if light_sprite:
			var iris_offset = iris_sprite.position - original_iris_pos
			var light_follow = Vector2(iris_offset.x * light_follow_strength.x, iris_offset.y * light_follow_strength.y)
			light_sprite.position = original_light_pos + light_follow

func enable_tracking() -> void:
	can_track = true
	opened.emit()

func disable_tracking() -> void:
	can_track = false

func open_eye() -> void:
	if anim_player.has_animation("open"):
		var anim = anim_player.get_animation("open")
		anim_player.play("open")

		# Check if the animation handles its own transparency
		var has_modulate_track = false
		for i in range(anim.get_track_count()):
			var path = str(anim.track_get_path(i))
			if path == "." or path == ".:modulate" or path == "modulate":
				has_modulate_track = true
				break

		if not has_modulate_track:
			modulate.a = 1.0
	else:
		# Fallback if no animation is set up yet
		modulate = Color.WHITE

	# Enable tracking regardless
	enable_tracking()

func look_at_player() -> void:
	disable_tracking()

	var iris_target = iris_sprite.position if iris_sprite else original_iris_pos
	var duration = 1.0

	if anim_player.has_animation("angry"):
		var anim = anim_player.get_animation("angry")
		duration = anim.length

		# We'll try to find both X and Y if they are split, or Vector2 if combined
		var target_x = iris_target.x
		var target_y = iris_target.y
		var found_x = false
		var found_y = false
		var found_vec = false

		for i in range(anim.get_track_count()):
			var path = str(anim.track_get_path(i))
			if "Iris" in path and "position" in path:
				var key_count = anim.track_get_key_count(i)
				if key_count > 0:
					var val = anim.track_get_key_value(i, key_count - 1)
					if path.ends_with(":x"):
						target_x = val
						found_x = true
					elif path.ends_with(":y"):
						target_y = val
						found_y = true
					elif path.ends_with(":position") or path.ends_with("position"):
						if val is Vector2:
							iris_target = val
							found_vec = true

				# Disable the track so it doesn't fight our Tween
				anim.track_set_enabled(i, false)

		if (found_x or found_y) and not found_vec:
			iris_target = Vector2(target_x, target_y)

		anim_player.play("angry")
	elif anim_player.has_animation("look_at_player"):
		var anim = anim_player.get_animation("look_at_player")
		duration = anim.length
		anim_player.play("look_at_player")

	# Smoothly tween iris to the calculated target over the full animation duration
	if iris_sprite:
		var tween = create_tween()
		tween.tween_property(iris_sprite, "position", iris_target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

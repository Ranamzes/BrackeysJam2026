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
@export var can_blink: bool = true
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
@onready var mask_node: Polygon2D = find_child("Mask", true, false)

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
		RenderingServer.canvas_item_set_parent(_debug_rid, get_canvas_item())
		RenderingServer.canvas_item_set_z_as_relative_to_parent(_debug_rid, false)
		RenderingServer.canvas_item_set_z_index(_debug_rid, 4096)

	RenderingServer.canvas_item_clear(_debug_rid)

	if not show_debug_radius:
		return

	_ensure_original_pos()
	if not iris_sprite:
		return

	var center = original_iris_pos + iris_center_offset
	var rot_rad = deg_to_rad(move_rotation)

	var points = PackedVector2Array()
	var sides: int = 64
	for i in range(sides + 1):
		var angle = float(i) * TAU / float(sides)
		var p = Vector2(cos(angle) * move_radius_x, sin(angle) * move_radius_y)
		points.push_back(center + p.rotated(rot_rad))
	RenderingServer.canvas_item_add_polyline(_debug_rid, points, PackedColorArray([Color.YELLOW]), 2.0)

	var cs: float = 15.0
	var h_dir = Vector2(cs, 0).rotated(rot_rad)
	var v_dir = Vector2(0, cs).rotated(rot_rad)
	RenderingServer.canvas_item_add_line(_debug_rid, center - h_dir, center + h_dir, Color.YELLOW, 1.0)
	RenderingServer.canvas_item_add_line(_debug_rid, center - v_dir, center + v_dir, Color.YELLOW, 1.0)
	RenderingServer.canvas_item_add_circle(_debug_rid, center, 3.0, Color.YELLOW)

func _update_all_textures() -> void:
	_update_texture("Mask/Base", base_texture)
	_update_texture("Mask/Iris", iris_texture)
	_update_texture("Mask/Shadow", shadow_texture)
	_update_texture("Mask/Light", light_texture)
	_update_texture("UpperLid", upper_lid_texture)
	_update_texture("LowerLid", lower_lid_texture)

func _update_texture(node_path: String, tex: Texture2D) -> void:
	var node = get_node_or_null(node_path)
	if not node:
		var node_name = node_path.split("/")[-1]
		node = find_child(node_name, true, false)

	if node:
		node.texture = tex

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_debug_overlay()
		return

	if light_sprite and light_jitter_intensity > 0:
		jitter_time += delta * light_jitter_speed
		var jitter = Vector2(
			sin(jitter_time) * cos(jitter_time * 0.7),
			cos(jitter_time * 0.8) * sin(jitter_time * 0.5)
		) * light_jitter_intensity
		light_sprite.offset = jitter

	if can_track:
		blink_timer -= delta
		if blink_timer <= 0:
			trigger_blink()

		var mouse_pos = get_viewport().get_mouse_position()
		var local_mouse = to_local(mouse_pos)

		var center = original_iris_pos + iris_center_offset
		var rel_mouse = local_mouse - center
		var rot_rad = deg_to_rad(move_rotation)
		var rotated_mouse = rel_mouse.rotated(-rot_rad)

		var unit_space_mouse = Vector2(
			rotated_mouse.x / max(0.01, move_radius_x),
			rotated_mouse.y / max(0.01, move_radius_y)
		)

		if unit_space_mouse.length() > 1.0:
			unit_space_mouse = unit_space_mouse.normalized()

		var clamped_rel = Vector2(
			unit_space_mouse.x * move_radius_x,
			unit_space_mouse.y * move_radius_y
		).rotated(rot_rad)

		iris_sprite.position = iris_sprite.position.lerp(center + clamped_rel, 5.0 * delta)

		if light_sprite:
			var iris_offset = iris_sprite.position - original_iris_pos
			var light_follow = Vector2(iris_offset.x * light_follow_strength.x, iris_offset.y * light_follow_strength.y)
			light_sprite.position = original_light_pos + light_follow

func enable_tracking() -> void:
	can_track = true
	opened.emit()

func disable_tracking() -> void:
	can_track = false

func trigger_blink() -> void:
	if can_blink and anim_player and anim_player.has_animation("blink"):
		anim_player.play("blink")
	blink_timer = randf_range(blink_min, blink_max)

func _input(event: InputEvent) -> void:
	if not can_track or Engine.is_editor_hint():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if mask_node:
			var local_pos = mask_node.to_local(get_global_mouse_position())
			if Geometry2D.is_point_in_polygon(local_pos, mask_node.polygon):
				trigger_blink()
				# IMPORTANT: Do not call set_input_as_handled()
				# so that the dialogue in intro.gd can still progress.

func open_eye() -> void:
	if anim_player.has_animation("open"):
		anim_player.play("open")
		var has_modulate_track = false
		for i in range(anim_player.get_animation("open").get_track_count()):
			var path = str(anim_player.get_animation("open").track_get_path(i))
			if path == "." or path == ".:modulate" or path == "modulate":
				has_modulate_track = true
				break
		if not has_modulate_track:
			modulate.a = 1.0
	else:
		modulate = Color.WHITE
	enable_tracking()

func look_at_player() -> void:
	disable_tracking()
	var iris_target = original_iris_pos + iris_center_offset
	var duration = 1.0

	var anim_name = ""
	if anim_player.has_animation("angry"):
		anim_name = "angry"
	elif anim_player.has_animation("look_at_player"):
		anim_name = "look_at_player"

	if anim_name != "":
		var anim = anim_player.get_animation(anim_name)
		duration = anim.length

		# Find the target position from the last key of the iris position tracks
		for i in range(anim.get_track_count()):
			var path = str(anim.track_get_path(i))
			if "Iris" in path and "position" in path:
				# Extract value from the last key
				var key_count = anim.track_get_key_count(i)
				if key_count > 0:
					var last_val = anim.track_get_key_value(i, key_count - 1)
					if last_val is Vector2:
						iris_target = last_val
					elif anim.track_get_type(i) == Animation.TYPE_BEZIER:
						# For bezier tracks, we might need to reconstruct the Vector2 from x and y tracks
						if ":x" in path:
							iris_target.x = last_val
						elif ":y" in path:
							iris_target.y = last_val

				# Disable the track so our tween can handle it smoothly
				anim.track_set_enabled(i, false)

		anim_player.play(anim_name)

	if iris_sprite:
		var tween = create_tween()
		tween.tween_property(iris_sprite, "position", iris_target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

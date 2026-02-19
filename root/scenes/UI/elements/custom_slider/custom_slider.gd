extends Control
class_name CustomSlider

signal value_changed(value: float)

@export var value: float = 0.0:
	set(new_val):
		value = clampf(new_val, min_value, max_value)
		_update_visuals()

@export var min_value: float = 0.0:
	set(new_val):
		min_value = new_val
		_update_visuals()

@export var max_value: float = 1.0:
	set(new_val):
		max_value = new_val
		_update_visuals()

@export var step: float = 0.01

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var grabber: TextureButton = $GrabberIcon

var _is_dragging: bool = false

func _ready() -> void:
	grabber.button_down.connect(_on_grabber_down)
	grabber.button_up.connect(_on_grabber_up)
	resized.connect(_update_visuals)
	_update_visuals.call_deferred()
	_update_visuals()

func _input(event: InputEvent) -> void:
	if not _is_dragging:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_is_dragging = false
		return

	if event is InputEventMouseMotion:
		_update_value_from_mouse(event.position.x)

func _on_grabber_down() -> void:
	_is_dragging = true

func _on_grabber_up() -> void:
	_is_dragging = false

# Allows clicking on the track itself to jump to a value
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_update_value_from_mouse(event.position.x)
		else:
			_is_dragging = false

func _update_value_from_mouse(_mouse_x: float) -> void:
	var local_x = get_local_mouse_position().x
	var ratio = clampf(local_x / size.x, 0.0, 1.0)

	var raw_val = lerpf(min_value, max_value, ratio)

	# Apply stepping
	if step > 0.0:
		raw_val = snapped(raw_val, step)

	var old_val = value
	value = raw_val

	if old_val != value:
		value_changed.emit(value)

func _update_visuals() -> void:
	if not is_inside_tree():
		return

	progress_bar.min_value = min_value
	progress_bar.max_value = max_value
	progress_bar.value = value

	# Update grabber position visually based on percentage
	var ratio = 0.0
	var range_val = max_value - min_value
	if range_val > 0:
		ratio = (value - min_value) / range_val

	# Center the grabber over the progress head
	var offset_x = (size.x * ratio) - (grabber.size.x / 2.0)
	grabber.position.x = clampf(offset_x, 0.0, size.x - grabber.size.x)

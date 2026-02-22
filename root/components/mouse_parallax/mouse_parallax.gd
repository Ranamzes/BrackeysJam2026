extends Node2D

@export var parallax_intensity: Vector2 = Vector2(20.0, 10.0)
@export var smooth_speed: float = 5.0

@onready var initial_position: Vector2 = position

func _process(delta: float) -> void:
    var viewport_size = get_viewport_rect().size
    var mouse_pos = get_viewport().get_mouse_position()

    # Calculate offset from center (-0.5 to 0.5)
    var offset = (mouse_pos / viewport_size) - Vector2(0.5, 0.5)

    # Target position is initial position plus parallax offset
    # Note: We use negative offset to make it look like it's in the foreground
    # (moving in the opposite direction of the mouse or faster)
    # Actually, foreground usually moves "more" or "against" the background.
    # If the camera were moving right, foreground would move left faster.
    # For mouse parallax: if mouse moves right, foreground (closer) should move left.
    var target_offset = offset * parallax_intensity * -1.0
    var target_pos = initial_position + target_offset

    position = position.lerp(target_pos, smooth_speed * delta)

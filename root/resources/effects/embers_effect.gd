@tool
class_name RichTextEmbers
extends RichTextEffect

var bbcode = "embers"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 50.0) # characters per second
	var freq: float = char_fx.env.get("freq", 5.0)
	var scale: float = char_fx.env.get("scale", 2.0)

	# --- Appearance / Transition Logic ---
	# Calculate when this character SHOULD appear based on index
	var reveal_time = char_fx.range.x / speed
	var progress = max(0.0, char_fx.elapsed_time - reveal_time)
	var arrival = clamp(progress * 4.0, 0.0, 1.0) # 0.25s reveal duration

	# --- Idle Animation Logic ---
	var r = char_fx.glyph_index * 12.34 + char_fx.elapsed_time * freq
	var wiggle = sin(r) * 0.5 + 0.5

	var orange = Color(1.0, 0.4, 0.0)
	var yellow = Color(1.0, 1.0, 0.0)
	var dark_red = Color(0.3, 0.0, 0.0)

	# Color: Reveal with a yellow flash, then fade into the ember flicker
	var ember_color = dark_red.lerp(orange, wiggle)
	char_fx.color = yellow.lerp(ember_color, arrival)

	# Transform: Scale up as it appears
	char_fx.transform = char_fx.transform.scaled(Vector2(arrival, arrival))

	# Movement: Chaotic wiggles
	char_fx.offset += Vector2(sin(r * 1.5) * scale, -cos(r * 0.8) * scale)

	return true

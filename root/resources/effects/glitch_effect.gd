@tool
class_name RichTextGlitch
extends RichTextEffect

var bbcode = "glitch"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 15.0)
	var strength: float = char_fx.env.get("strength", 2.0)

	# Create a random value based on time and character index
	var time = char_fx.elapsed_time * speed
	var seed_val = char_fx.glyph_index + int(time)

	# Simple pseudo-random function
	var rand_val = sin(seed_val * 12.9898) * 43758.5453
	rand_val = rand_val - floor(rand_val)

	if rand_val < 0.1: # 10% chance to glitch per frame/step
		# Random offset
		char_fx.offset = Vector2(
			(rand_val * 2.0 - 1.0) * strength,
			(sin(seed_val) * 2.0 - 1.0) * strength
		)

		# Random color shift (RGB split feel)
		if rand_val < 0.05:
			char_fx.color = Color(1.0, 0.2, 0.2) # Reddish
		else:
			char_fx.color = Color(0.2, 1.0, 1.0) # Cyanish
	else:
		char_fx.offset = Vector2.ZERO

	return true

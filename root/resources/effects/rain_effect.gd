@tool
class_name RichTextRain
extends RichTextEffect

var bbcode = "rain"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 8.0)

	# Create pseudo-random drop timing based on index
	var r = char_fx.glyph_index * 33.33 + char_fx.glyph_index * 4545.5454
	var t = fmod(r + char_fx.elapsed_time * 0.5, 1.0)

	char_fx.offset.y += t * scale
	char_fx.color = char_fx.color.lerp(Color.TRANSPARENT, t)

	return true

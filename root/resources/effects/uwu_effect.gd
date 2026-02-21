@tool
class_name RichTextUwU
extends RichTextEffect

var bbcode = "uwu"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 4.0)

	var t = sin(char_fx.glyph_index * 2.0 + char_fx.elapsed_time * freq)
	char_fx.color = Color.PINK.lerp(Color.WHITE, t * 0.5 + 0.5)
	char_fx.offset.y += cos(char_fx.glyph_index * 2.5 + char_fx.elapsed_time * freq) * 2.0

	return true

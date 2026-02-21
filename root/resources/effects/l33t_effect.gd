@tool
class_name RichTextL33t
extends RichTextEffect

var bbcode = "l33t"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 5.0)
	var t = sin(char_fx.glyph_index * 12.3 + char_fx.elapsed_time * freq)

	char_fx.color = Color.GREEN.lerp(Color.WHITE, t * 0.5 + 0.5)
	if t > 0.8:
		char_fx.offset.y -= 2.0

	return true

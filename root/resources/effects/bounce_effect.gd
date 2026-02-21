@tool
class_name RichTextBounce
extends RichTextEffect

var bbcode = "bounce"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 6.0)
	var freq: float = char_fx.env.get("freq", 5.0)

	var r = char_fx.glyph_index * 0.8 - char_fx.elapsed_time * freq
	var bounce = max(0.0, sin(r)) * scale

	char_fx.offset.y -= bounce
	return true

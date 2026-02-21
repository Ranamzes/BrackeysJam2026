@tool
class_name RichTextPrickle
extends RichTextEffect

var bbcode = "prickle"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 2.0)
	var freq: float = char_fx.env.get("freq", 12.0)

	var r = char_fx.glyph_index * 14.5 + char_fx.elapsed_time * freq
	if sin(r) > 0.9:
		char_fx.offset.y -= scale * 2.0
		char_fx.offset.x += (cos(r * 2.0) * scale)

	return true

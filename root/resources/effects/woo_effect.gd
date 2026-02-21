@tool
class_name RichTextWoo
extends RichTextEffect

var bbcode = "woo"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 2.0)
	var freq: float = char_fx.env.get("freq", 4.0)

	var r = char_fx.glyph_index * 1.5 + char_fx.elapsed_time * freq
	var offset_y = sin(r) * scale

	char_fx.offset.y += offset_y
	return true

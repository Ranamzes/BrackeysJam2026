@tool
class_name RichTextNervous
extends RichTextEffect

var bbcode = "nervous"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var scale: float = char_fx.env.get("scale", 2.0)
	var freq: float = char_fx.env.get("freq", 8.0)

	var r = char_fx.glyph_index * 33.33 + char_fx.elapsed_time * freq * 10.0
	var offset_x = sin(r * 2.1) * scale
	var offset_y = cos(r * 1.7) * scale

	char_fx.offset += Vector2(offset_x, offset_y)
	return true
